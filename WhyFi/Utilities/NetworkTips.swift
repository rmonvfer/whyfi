//
//  NetworkTips.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct NetworkTip: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let severity: Severity

    enum Severity: Comparable {
        case info
        case warning
        case critical

        var color: Color {
            switch self {
            case .info: .blue
            case .warning: .orange
            case .critical: .red
            }
        }

        var icon: String {
            switch self {
            case .info: "info.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .critical: "exclamationmark.octagon.fill"
            }
        }
    }
}

enum NetworkTips {
    static func analyze(wifi: WiFiMetrics, router: PingMetrics, internet: PingMetrics) -> [NetworkTip] {
        var tips: [NetworkTip] = []

        // Critical: Very weak signal
        if wifi.rssi < -80 {
            tips.append(NetworkTip(
                title: "Very Weak Signal",
                message: "Move closer to your router or remove obstructions.",
                severity: .critical
            ))
        }

        // Critical: High packet loss
        if internet.packetLoss > 10 {
            tips.append(NetworkTip(
                title: "High Packet Loss",
                message: "Your connection is unstable. Try restarting your router.",
                severity: .critical
            ))
        }

        // Warning: Using 2.4 GHz with low link rate
        if wifi.frequencyBand == .twoPointFourGHz && wifi.linkRate < 150 {
            tips.append(NetworkTip(
                title: "Slow Wi-Fi Standard",
                message: "Using Wi-Fi 4. Try connecting to 5 GHz for better speeds.",
                severity: .warning
            ))
        }

        // Warning: Weak signal (but not critical)
        if wifi.rssi >= -80 && wifi.rssi < -70 {
            tips.append(NetworkTip(
                title: "Weak Signal",
                message: "Consider moving closer to your router.",
                severity: .warning
            ))
        }

        // Warning: High noise floor
        if wifi.noise > -80 {
            tips.append(NetworkTip(
                title: "Interference Detected",
                message: "Other devices may be affecting your connection.",
                severity: .warning
            ))
        }

        // Warning: Poor SNR (Signal-to-Noise Ratio)
        if wifi.snr < 20 && wifi.rssi >= -70 {
            tips.append(NetworkTip(
                title: "Poor Signal Quality",
                message: "Try changing your router's channel to reduce interference.",
                severity: .warning
            ))
        }

        // Warning: High latency to router
        if router.latency > 10 && router.isReachable {
            tips.append(NetworkTip(
                title: "Router Latency",
                message: "Your local network may be congested.",
                severity: .warning
            ))
        }

        // Warning: High internet latency
        if internet.latency > 100 && internet.isReachable {
            tips.append(NetworkTip(
                title: "High Latency",
                message: "This may affect video calls and gaming.",
                severity: .warning
            ))
        }

        // Warning: High jitter
        if internet.jitter > 30 && internet.isReachable {
            tips.append(NetworkTip(
                title: "Unstable Connection",
                message: "High jitter may cause audio/video issues.",
                severity: .warning
            ))
        }

        // Info: On 2.4 GHz but could use 5 GHz
        if wifi.frequencyBand == .twoPointFourGHz && wifi.rssi > -60 && wifi.linkRate >= 150 {
            tips.append(NetworkTip(
                title: "5 GHz Available?",
                message: "You have good signal. 5 GHz may offer faster speeds.",
                severity: .info
            ))
        }

        // Sort by severity (critical first)
        return tips.sorted { $0.severity > $1.severity }
    }

    static func worstSeverity(from tips: [NetworkTip]) -> NetworkTip.Severity? {
        tips.first?.severity
    }
}
