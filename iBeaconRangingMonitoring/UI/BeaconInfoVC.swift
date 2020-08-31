//
//  BeaconInfoVC.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 30.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

// App for iBeacon simulation: https://apps.apple.com/ru/app/locate-beacon/id738709014?l=en

// TODO:
// add location region notif triger (when user is on some range near the shop, remind about the app) // do not require the Always location // UNLocationNotificationTrigger
// record when the user come inside of range // userDefaults or firebase (analytics)
// iOS 13? need older?
// investigate how to monitor more then 20 different constraints regions

// problem:
// need Always location, Background App Refresh, low energy mode

import UIKit
import CoreLocation

final class BeaconInfoVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var beaconRegionStateLabel: UILabel!
    @IBOutlet private weak var beaconInfoLabel: UILabel!

    private let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    private let beaconUUIDString = "012f62c2-ee7c-4591-9ea3-b94943de7bbb"
    
    private let dbClient = FirestoreClient()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissions()
    }
    
    // MARK: - Methods
    
    private func startMonitoring() {
        guard let beaconUUID = UUID(uuidString: beaconUUIDString) else {
            return
        }
        let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint,
                                          identifier: beaconUUID.uuidString)
        locationManager.startMonitoring(for: beaconRegion)
//        // TODO: default is true, can be removed
//        beaconRegion.notifyOnEntry = true
//        beaconRegion.notifyOnExit = true
    }
}

// MARK: - Location Delegate
extension BeaconInfoVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        printDebugMessage(for: Self.self, message: "Location status: \(status.description)")
        
        switch status {
        case .authorizedWhenInUse:
            startMonitoring()
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
//            manager.allowsBackgroundLocationUpdates = true
            startMonitoring()
        default:
            break
        }
    }
    
    // MARK: - Beacon
   
    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        switch state {
        case .inside:
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        case .outside, .unknown:
            dbClient.isRecorded = false
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
        notificationCenter.scheduleBeaconNotification(by: state)
        updateRegionStateLabel(by: state)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRange beacons: [CLBeacon],
                         satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        guard let beacon = beacons.first else {
            return
        }
        
        // testing internet request in background
        dbClient.incrementCounter()

        let beaconMajorValue = beacon.major.uint16Value
        notificationCenter.scheduleNotification(
            with: """
            didRange beacon: major - \(beaconMajorValue),
            proximity: \(beacon.proximity.description)
            """
        )
        updateBeaconInfoLabel(about: beacon)
    }
}

// MARK: - Subviews
private extension BeaconInfoVC {
    func updateRegionStateLabel(by regionState: CLRegionState) {
        switch regionState {
        case .inside:
            beaconRegionStateLabel.text = "Inside of the beacon range"
        case .outside:
            beaconRegionStateLabel.text = "Outside of the beacon range"
        case .unknown:
            beaconRegionStateLabel.text = "Unknown beacon range"
        }
        
        printDebugMessage(for: Self.self, message: beaconRegionStateLabel.text ?? "")
    }
    
    func updateBeaconInfoLabel(about beacon: CLBeacon) {
        beaconInfoLabel.text =
        """
        UUID: \(beacon.uuid.uuidString)
        major: \(beacon.major)
        minor: \(beacon.minor)
        proximity: \(beacon.proximity.description)
        accuracy: \(String(format: "%.2f", beacon.accuracy))m
        signal: \(beacon.rssi)
        """
        
        printDebugMessage(for: Self.self, message: beaconInfoLabel.text ?? "")
    }
}

// MARK: - Permissions
private extension BeaconInfoVC {
    func requestPermissions() {
        // notif
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { _, _ in }
        // location
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
