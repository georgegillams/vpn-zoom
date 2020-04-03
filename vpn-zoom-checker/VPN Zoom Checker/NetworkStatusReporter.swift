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

    let networkInterface: String!
    let networkInterfaceStatus: String!

    init(withNetworkInterface networkInterface: String, networkInterfaceStatus: String) {
        self.networkInterface = networkInterface
        self.networkInterfaceStatus = networkInterfaceStatus
    }

    func conditionSatisfied() -> Bool {
        let task = Process()
        task.launchPath = "/sbin/ifconfig"
        task.arguments = [self.networkInterface]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        if output.range(of:self.networkInterfaceStatus) != nil {
            return true
        }else {
            return false
        }
    }

}

