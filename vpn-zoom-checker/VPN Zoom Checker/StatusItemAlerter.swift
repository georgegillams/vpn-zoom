//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa

class StatusItemAlerter: NSObject {

    let statusItem: NSStatusItem?
    var alerterTimer: Timer?
    var statusItemImage = "StatusBarButtonImage"

    init(withStatusItem statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }

    func start() {
        if(self.alerterTimer == nil) {
            DispatchQueue.main.async {
                self.alerterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.alternateIcon), userInfo: nil, repeats: true)
            }
        }
    }

    @objc func alternateIcon() {
        self.statusItemImage = self.statusItemImage == "StatusBarButtonImage" ? "StatusBarButtonImageAlert" : "StatusBarButtonImage"
        DispatchQueue.main.async {
            self.statusItem?.button?.image = NSImage(named:NSImage.Name(self.statusItemImage))
        }
    }

    func stop() {
        if(self.alerterTimer != nil) {
            self.alerterTimer?.invalidate()
            self.alerterTimer = nil
            DispatchQueue.main.async {
                self.statusItemImage = "StatusBarButtonImage"
                self.statusItem?.button?.image = NSImage(named:NSImage.Name(self.statusItemImage))
            }
        }
    }

}

