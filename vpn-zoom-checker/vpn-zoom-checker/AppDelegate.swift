//
//  AppDelegate.swift
//  vpn-zoom-checker
//
//  Created by George Gillams on 31/03/2020.
//  Copyright © 2020 George Gillams. All rights reserved.
//

import Cocoa
import SwiftUI
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    var statusItem: NSStatusItem?
    var menu: NSMenu?
    var zoomStatusReporter: AppStatusReporter?
    var vpnStatusReporter: NetworkStatusReporter?
    var checkStatusTimer: Timer?
    let notificationIdentifier = "ZOOM_VPN_NOTIFICATION"
    var minNextNotificationDate: Date = Date(timeIntervalSince1970: TimeInterval(0.0))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.requestNotificationPermissions()
        self.constructStatusBarButton()
        self.constructReporters()

        self.checkStatusTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
    }

    func requestNotificationPermissions () {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
          granted, error in
          if granted {
            print("Approval granted to send notifications")
          } else {
            print(error)
          }
        }

        UNUserNotificationCenter.current().delegate = self
    }

   func constructReporters(){
        zoomStatusReporter = AppStatusReporter(withAppIdentifier: "us.zoom.xos")
                vpnStatusReporter = NetworkStatusReporter(withNetworkInterface: "gpd0", networkInterfaceStatus: "UP")
    }

    func constructStatusBarButton() {
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = self.statusItem?.button {
          button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        self.constructMenu()
    }

    func constructMenu() {
        self.menu = NSMenu()

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.menu?.addItem(NSMenuItem(title: "Version \(version)", action: nil, keyEquivalent: "") )
        }
        self.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        self.statusItem?.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        checkStatusTimer?.invalidate()
    }

    @objc func checkStatus()
    {
        DispatchQueue.global(qos: .background).async {
            let timeNow = NSDate()
            if timeNow.compare(self.minNextNotificationDate) == ComparisonResult.orderedDescending {
                let onZoomCall = self.zoomStatusReporter?.conditionSatisfied() ?? false
                let onVPN = self.vpnStatusReporter?.conditionSatisfied() ?? false

                if(onZoomCall && onVPN){
                    DispatchQueue.main.async {
                        print("WARN USER NOW")
                        self.sendNotification()
                        // Don't notify for another 30 mins
                        self.minNextNotificationDate = timeNow.addingTimeInterval(1800) as Date
                    }
                }
            }
        }
    }

    func sendNotification() {
      // Create Notification content
      let notificationContent = UNMutableNotificationContent()

      notificationContent.title = "Zoom over VPN warning"
      notificationContent.body = "If possible, please disconnect from the VPN 🌎 while you use Zoom 📹. Thanks 🙇‍♂️"
      notificationContent.sound = UNNotificationSound.default

      // Create Notification trigger
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

      let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: trigger)

      UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
        if error != nil {
          print("\(error)")
        } else {
        }
      })
    }

    // pragma - UserNotificationDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler(.alert)
    }

}

