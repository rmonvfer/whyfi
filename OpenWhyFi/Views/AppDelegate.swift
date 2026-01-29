//
//  AppDelegate.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var monitor: NetworkMonitor!
    private var locationManager: LocationManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor = NetworkMonitor()
        locationManager = LocationManager()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "wifi", accessibilityDescription: "WiFi")
            button.action = #selector(togglePopover)
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: Constants.panelWidth, height: 500)
        popover.behavior = .transient
        popover.animates = true

        let contentView = PopupPanelView()
            .environment(monitor)
            .environment(locationManager)

        popover.contentViewController = NSHostingController(rootView: contentView)

        monitor.startMonitoring()
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
