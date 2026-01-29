//
//  SettingsManager.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation
import ServiceManagement
import Observation

enum MenuBarMetric: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case rssi = "Signal"
    case noise = "Noise"
    case linkRate = "Link Rate"
    case routerLatency = "Router Ping"
    case internetLatency = "Internet Ping"
    case packetLoss = "Packet Loss"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .none: ""
        case .rssi: "SIG"
        case .noise: "NSE"
        case .linkRate: "LNK"
        case .routerLatency: "RTR"
        case .internetLatency: "NET"
        case .packetLoss: "LSS"
        }
    }

    var unit: String {
        switch self {
        case .none: ""
        case .rssi, .noise: "dB"
        case .linkRate: "Mbps"
        case .routerLatency, .internetLatency: "ms"
        case .packetLoss: "%"
        }
    }
}

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

    var menuBarMetrics: [MenuBarMetric] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "menuBarMetrics"),
                  let metrics = try? JSONDecoder().decode([MenuBarMetric].self, from: data) else {
                return [.none, .none, .none]
            }
            return metrics
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "menuBarMetrics")
                NotificationCenter.default.post(name: .iconStyleChanged, object: nil)
            }
        }
    }

    func setMenuBarMetric(at index: Int, to metric: MenuBarMetric) {
        var metrics = menuBarMetrics
        while metrics.count <= index {
            metrics.append(.none)
        }
        metrics[index] = metric
        menuBarMetrics = metrics
    }

    private init() {}
}

extension Notification.Name {
    static let iconStyleChanged = Notification.Name("iconStyleChanged")
    static let resetStats = Notification.Name("resetStats")
}
