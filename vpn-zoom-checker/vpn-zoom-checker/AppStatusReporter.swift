//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa

class AppStatusReporter: StatusReporter {

    var appIdentifier: String = ""

    init(withAppIdentifier appIdentifier: String) {
        self.appIdentifier = appIdentifier
    }

    override func conditionSatisfied() -> Bool {
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications
        for app in applications {
            if app.bundleIdentifier == self.appIdentifier {
                return true
            }
        }
        return false
    }

}

