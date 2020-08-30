//
//  Debug.swift
//  iBeaconRangingMonitoring
//
//  Created by Orest Patlyka on 30.08.2020.
//  Copyright © 2020 Orest Patlyka. All rights reserved.
//

import Foundation

public func optimizedPrint(_ items: Any...) {
    #if DEBUG
    Swift.print(items[0])
    #endif
}

public func printDebugMessage<T>(for type: T.Type, message: String) {
    optimizedPrint("[\(String(describing: T.self))] \(message)")
}

public func printDeinitDebugMessage<T>(for type: T.Type) {
    printDebugMessage(for: type, message: "-> DEINITED")
}
