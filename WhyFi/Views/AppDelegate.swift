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
    private var iconStyleObserver: NSObjectProtocol?
    private var resetStatsObserver: NSObjectProtocol?

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

        iconStyleObserver = NotificationCenter.default.addObserver(
            forName: .iconStyleChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateIcon(quality: self?.lastQuality ?? .disconnected)
        }

        resetStatsObserver = NotificationCenter.default.addObserver(
            forName: .resetStats,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.monitor.resetStats()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        iconUpdateTimer?.invalidate()
        if let observer = iconStyleObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = resetStatsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
        let colorful = SettingsManager.shared.colorfulIcon
        let selectedMetrics = SettingsManager.shared.menuBarMetrics

        let metricValues = selectedMetrics.compactMap { metric in
            MenuBarMetricValue.from(metric: metric, state: monitor.state)
        }

        if metricValues.isEmpty {
            button.image = MenuBarIconRenderer.createImage(for: quality, colorful: colorful)
        } else {
            button.image = MenuBarIconRenderer.createImageWithMetrics(
                for: quality,
                colorful: colorful,
                metrics: metricValues
            )
        }
    }
}
