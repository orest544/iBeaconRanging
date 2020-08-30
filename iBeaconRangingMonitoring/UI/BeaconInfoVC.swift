//
//  BeaconInfoVC.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 30.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

import UIKit
import CoreLocation

final class BeaconInfoVC: UIViewController {
    
    private let locationManager = CLLocationManager()
    private let beaconUUIDString = "012f62c2-ee7c-4591-9ea3-b94943de7bbb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
//        locationManager.allowsBackgroundLocationUpdates = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startMonitoring()
    }
    
    private func startMonitoring() {
        guard let beaconUUID = UUID(uuidString: beaconUUIDString) else {
            return
        }
        
        let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint,
                                          identifier: beaconUUID.uuidString)
        
        locationManager.startMonitoring(for: beaconRegion)
    }

}

// MARK: - Location Delegate
extension BeaconInfoVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        
        switch state {
        case .inside:
            printDebugMessage(for: Self.self, message: "locationManager didDetermineState: inside")
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        case .outside:
            printDebugMessage(for: Self.self, message: "locationManager didDetermineState: outside")
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        case .unknown:
            printDebugMessage(for: Self.self, message: "locationManager didDetermineState: unknown")
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRange beacons: [CLBeacon],
                         satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print(beacons)
    }
    
    
    // Apple's alternative
//    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
//        /*
//         Beacons are categorized by proximity. A beacon can satisfy
//         multiple constraints and can be displayed multiple times.
//         */
//        beaconConstraints[beaconConstraint] = beacons
//
//        self.beacons.removeAll()
//
//        var allBeacons = [CLBeacon]()
//
//        for regionResult in beaconConstraints.values {
//            allBeacons.append(contentsOf: regionResult)
//        }
//
//        for range in [CLProximity.unknown, .immediate, .near, .far] {
//            let proximityBeacons = allBeacons.filter { $0.proximity == range }
//            if !proximityBeacons.isEmpty {
//                self.beacons[range] = proximityBeacons
//            }
//        }
//
//        tableView.reloadData()
//    }
}
