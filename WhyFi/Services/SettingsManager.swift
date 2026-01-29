//
//  SettingsManager.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation
import ServiceManagement
import Observation

@Observable
@MainActor
final class SettingsManager {
    static let shared = SettingsManager()

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }

    var colorfulIcon: Bool {
        get {
            UserDefaults.standard.object(forKey: "colorfulIcon") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "colorfulIcon")
            NotificationCenter.default.post(name: .iconStyleChanged, object: nil)
        }
    }

    private init() {}
}

extension Notification.Name {
    static let iconStyleChanged = Notification.Name("iconStyleChanged")
    static let resetStats = Notification.Name("resetStats")
}
