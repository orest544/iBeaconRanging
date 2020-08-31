//
//  FirestoreService.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 31.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class FirestoreClient {
    
    var isRecorded = false
    private var isRecording = false
    
    func incrementCounter() {
        if isRecorded || isRecording {
            return
        }
        isRecording = true
        Firestore.firestore().collection("counter").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                self?.isRecording = false
                UNUserNotificationCenter.current().scheduleNotification(with: "Error getting documents: \(error)")
                return
            }
            let counterDocument = snapshot!.documents.first
            let counterData = counterDocument?.data()
            let counterValue = counterData!["counterValue"] as! Int
            
            let newCounterValue = counterValue + 1
            counterDocument?.reference.updateData(["counterValue": newCounterValue]) { (error) in
                if let error = error {
                    self?.isRecording = false
                    UNUserNotificationCenter.current().scheduleNotification(with: "Error getting documents: \(error)")
                    return
                }
                self?.isRecorded = true
                self?.isRecording = false
                UNUserNotificationCenter.current().scheduleNotification(with: "Value recorder to DB!")
            }
        }
    }
}
