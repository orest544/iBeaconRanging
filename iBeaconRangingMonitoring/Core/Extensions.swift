//
//  Extensions.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 30.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

import CoreLocation
import UserNotifications

extension CLProximity {
    var description: String {
        switch self {
        case .immediate:
            return "immediate"
        case .near:
            return "near"
        case .far:
            return "far"
        case .unknown:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        @unknown default:
            return "denied"
        }
    }
}

extension UNUserNotificationCenter {
    func scheduleBeaconNotification(by regionState: CLRegionState) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        
        content.title = "Beacon"
        switch regionState {
        case .inside:
            content.body = "Inside of the beacon range"
        case .outside:
            content.body = "Outside of the beacon range"
        case .unknown:
            content.body = "Unknown beacon range"
        }
        
        let identifier = "BeaconRegionState\(regionState.rawValue)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        add(request) { (error) in
            if let error = error {
                printDebugMessage(for: Self.self, message: "UNNotificationRequest Error \(error.localizedDescription)")
            } else {
                printDebugMessage(for: Self.self, message: "UNNotificationRequest Success")
            }
        }
    }
}
