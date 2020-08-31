//
//  Extensions.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 30.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

import CoreLocation
import UserNotifications

// MARK: - User Notifications

extension UNMutableNotificationContent {
    static func make() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        content.title = "Beacon"
        return content
    }
}

extension UNTimeIntervalNotificationTrigger {
    static func make() -> UNTimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    }
}

extension UNUserNotificationCenter {
    func scheduleBeaconNotification(by regionState: CLRegionState) {
        let content: UNMutableNotificationContent = .make()
        switch regionState {
        case .inside:
            content.body = "Inside of the beacon range"
        case .outside:
            content.body = "Outside of the beacon range"
        case .unknown:
            content.body = "Unknown beacon range"
        }
        
        let identifier = "BeaconRegionState\(regionState.rawValue)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger.make()
        )
        addRequest(request)
    }
    
    func scheduleNotification(with text: String) {
        let content: UNMutableNotificationContent = .make()
        content.sound = .none
        content.body = text
        let requset = UNNotificationRequest(
            identifier: text,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger.make()
        )
        addRequest(requset)
    }
    
    private func addRequest(_ request: UNNotificationRequest) {
        add(request) { (error) in
            if let error = error {
                printDebugMessage(for: Self.self, message: "UNNotificationRequest Error \(error.localizedDescription)")
            } else {
                printDebugMessage(for: Self.self, message: "UNNotificationRequest Success")
            }
        }
    }
}

// MARK: - User friendly descriptions

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
