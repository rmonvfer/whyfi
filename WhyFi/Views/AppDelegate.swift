//
//  AppDelegate.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import AppKit
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var monitor: NetworkMonitor!
    private var locationManager: LocationManager!
    private var iconUpdateTimer: Timer?
    private var lastQuality: ConnectionQuality = .disconnected

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor = NetworkMonitor()
        locationManager = LocationManager()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateIcon(quality: .disconnected)
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

        iconUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateIconFromState()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        iconUpdateTimer?.invalidate()
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

    private func updateIconFromState() {
        Task { @MainActor in
            let quality = ConnectionQuality(from: monitor.state)
            if quality != lastQuality {
                lastQuality = quality
                updateIcon(quality: quality)
            }
        }
    }

    private func updateIcon(quality: ConnectionQuality) {
        guard let button = statusItem.button else { return }
        button.image = MenuBarIconRenderer.createImage(for: quality)
    }
}
