//
//  SignalQuality.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

enum SignalQuality: Sendable {
    case excellent
    case good
    case fair
    case weak
    case poor
    case disconnected

    init(rssi: Int) {
        switch rssi {
        case _ where rssi >= -50: self = .excellent
        case -60 ..< -50: self = .good
        case -70 ..< -60: self = .fair
        case -80 ..< -70: self = .weak
        default: self = .poor
        }
    }

    var color: Color {
        switch self {
        case .excellent, .good: .green
        case .fair: .yellow
        case .weak: .orange
        case .poor, .disconnected: .red
        }
    }

    var displayName: String {
        switch self {
        case .excellent: "Excellent"
        case .good: "Good"
        case .fair: "Fair"
        case .weak: "Weak"
        case .poor: "Poor"
        case .disconnected: "Disconnected"
        }
    }

    var tip: String {
        switch self {
        case .excellent:
            "Your signal is excellent. You should experience optimal performance."
        case .good:
            "Your signal is good. Performance should be reliable."
        case .fair:
            "Your signal is fair. Consider moving closer to your router."
        case .weak:
            "Your signal is weak. Try moving closer to your router or reducing interference."
        case .poor:
            "Your signal is very weak. Connection may be unreliable."
        case .disconnected:
            "Not connected to any WiFi network."
        }
    }
}

enum LatencyQuality: Sendable {
    case excellent
    case good
    case fair
    case poor

    init(latency: Double) {
        switch latency {
        case 0..<20: self = .excellent
        case 20..<50: self = .good
        case 50..<100: self = .fair
        default: self = .poor
        }
    }

    var color: Color {
        switch self {
        case .excellent, .good: .green
        case .fair: .yellow
        case .poor: .red
        }
    }
}
