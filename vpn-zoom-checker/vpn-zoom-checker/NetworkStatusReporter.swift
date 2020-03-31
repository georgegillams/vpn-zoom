//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa
import NetworkExtension

class NetworkStatusReporter: StatusReporter {

    var networkInterface: String = ""
    var networkInterfaceStatus: String = ""
    var cachedValue: Bool = false
    var cacheExpiry: Date = Date(timeIntervalSince1970: TimeInterval(0.0))

    init(withNetworkInterface networkInterface: String, networkInterfaceStatus: String) {
        self.networkInterface = networkInterface
        self.networkInterfaceStatus = networkInterfaceStatus
    }

    override func conditionSatisfied() -> Bool {
        let timeNow = NSDate()
        if timeNow.compare(self.cacheExpiry) == ComparisonResult.orderedAscending {
            return cachedValue
        }

        let task = Process()
        task.launchPath = "/sbin/ifconfig"
        task.arguments = [self.networkInterface]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        // Cache value for 30 seconds
        self.cacheExpiry = timeNow.addingTimeInterval(30) as Date

        if output.range(of:self.networkInterfaceStatus) != nil {
            self.cachedValue = true
        }else {
            self.cachedValue = false
        }

        return self.cachedValue
    }

}

