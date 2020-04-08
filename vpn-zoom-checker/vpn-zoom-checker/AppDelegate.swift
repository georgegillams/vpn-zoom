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

    var statusItem: NSStatusItem!
    var startOnBootMenuItem: NSMenuItem!
    var menu: NSMenu!
    var zoomStatusReporter: OrStatusReporter!
    var vpnStatusReporter: OrStatusReporter!
    var launchAgentHelper: LaunchAgentHelper!
    var checkStatusTimer: Timer!
    let notificationIdentifier = "ZOOM_VPN_NOTIFICATION"
    var minNextNotificationDate: Date = Date(timeIntervalSince1970: TimeInterval(0.0))
    var statusItemAlerter: StatusItemAlerter!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.requestNotificationPermissions()
        self.constructStatusBarButton()
        self.constructReporters()
        self.constructStatusItemAlerter()

        self.checkStatusTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
    }

    func constructStatusItemAlerter() {
        self.statusItemAlerter = StatusItemAlerter(withStatusItem: self.statusItem!)
    }

    func requestNotificationPermissions () {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) {
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
        zoomStatusReporter = OrStatusReporter()
        zoomStatusReporter?.add(statusReporter: AppStatusReporter(withAppIdentifier: "us.zoom.CptHost"))

        vpnStatusReporter = OrStatusReporter()
        vpnStatusReporter?.add(statusReporter: NetworkStatusReporter(withNetworkInterface: "gpd0", networkInterfaceStatus: "UP"))
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
        self.startOnBootMenuItem = NSMenuItem(title: "Start on system boot", action: #selector(self.toggleStartOnBoot), keyEquivalent: "")

        self.menu?.addItem(NSMenuItem(title: "About Zoom VPN checker", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "") )
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.menu?.addItem(NSMenuItem(title: "Version \(version)", action: nil, keyEquivalent: "") )
        }
        self.menu?.addItem(self.startOnBootMenuItem)
        self.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        self.statusItem?.menu = menu

        self.launchAgentHelper = LaunchAgentHelper(menuItem: self.startOnBootMenuItem)
        self.launchAgentHelper.updateMenuImage()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        checkStatusTimer?.invalidate()
    }

    @objc func toggleStartOnBoot()
    {
        self.launchAgentHelper.toggleStartOnBoot()
    }

    @objc func checkStatus()
    {
        DispatchQueue.global(qos: .background).async {
            let onZoomCall = self.zoomStatusReporter?.conditionSatisfied() ?? false

            if(onZoomCall) {
                let onVPN = self.vpnStatusReporter?.conditionSatisfied() ?? false

                if(onVPN){
                    print("Using VPN and Zoom")
                    self.statusItemAlerter!.start()

                    DispatchQueue.main.async {
                        let timeNow = NSDate()
                        if timeNow.compare(self.minNextNotificationDate) == ComparisonResult.orderedDescending {
                            print("Notifying user")
                            self.sendNotification(withTime: timeNow)
                            // Don't notify for another 30 mins
                            self.minNextNotificationDate = timeNow.addingTimeInterval(1800) as Date
                        }
                    }
                } else {
                    self.statusItemAlerter!.stop()
                }
            } else {
                self.statusItemAlerter!.stop()
            }
        }
    }

    func sendNotification(withTime time: NSDate) {
        // Create Notification content
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = "Zoom over VPN warning"
        notificationContent.body = "If possible, please disconnect from the VPN 🌎 while you use Zoom 📹\n" +
            "Thanks 🙇‍♂️\n" +
        "I won't notify you again for 30 mins ⏱"
        notificationContent.sound = UNNotificationSound.default

        // Create Notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "\(notificationIdentifier)_\(time.timeIntervalSince1970)", content: notificationContent, trigger: trigger)

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

