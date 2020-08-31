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
    func scheduleBeaconNotification(by regionState: CLRegionState, major: UInt16? = nil) {
        let identifier = "BeaconRegionState\(regionState.rawValue)\(major ?? 0)"
        
        getPendingNotificationRequests { [weak self] (notifications) in
            let alreadyScheduledNotification = notifications.first { $0.identifier == identifier }
            guard alreadyScheduledNotification == nil else {
                return
            }
            
            let content = UNMutableNotificationContent()
            content.sound = .default
            content.badge = 1
            content.title = "Beacon"
            switch regionState {
            case .inside:
                content.body = "Inside of the beacon range, with MAJOR: \(String(describing: major))"
            case .outside:
                content.body = "Outside of the beacon range"
            case .unknown:
                content.body = "Unknown beacon range"
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self?.add(request) { (error) in
                if let error = error {
                    printDebugMessage(for: Self.self, message: "UNNotificationRequest Error \(error.localizedDescription)")
                } else {
                    printDebugMessage(for: Self.self, message: "UNNotificationRequest Success")
                }
            }
        }
    }
}
