//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa

class OrStatusReporter: StatusReporter {

    var statusReporters = [StatusReporter]()

    init() {
    }

    func add(statusReporter: StatusReporter) {
        self.statusReporters.append(statusReporter)
    }

    func conditionSatisfied() -> Bool {
        for statusReporter in self.statusReporters {
            if statusReporter.conditionSatisfied() {
                return true
            }
        }
        return false
    }

}

