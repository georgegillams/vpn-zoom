//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa
import LaunchAtLogin

class LaunchAgentHelper: NSObject {

    let menuItem: NSMenuItem!

    init(menuItem: NSMenuItem) {
        self.menuItem = menuItem
    }

    func toggleStartOnBoot() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        self.updateMenuImage()
    }

    func startOnBootEnabled() -> Bool {
        return LaunchAtLogin.isEnabled
    }

    func updateMenuImage() {
        if self.startOnBootEnabled() {
            self.menuItem.image = NSImage(named:NSImage.Name("TickImage"))
        } else {
            self.menuItem.image = nil
        }
    }
}

