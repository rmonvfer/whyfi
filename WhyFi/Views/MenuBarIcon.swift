//
//  MenuBarIcon.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import AppKit
import SwiftUI

enum ConnectionQuality {
    case excellent
    case good
    case fair
    case poor
    case disconnected

    var color: NSColor {
        switch self {
        case .excellent, .good: .systemGreen
        case .fair: .systemYellow
        case .poor: .systemOrange
        case .disconnected: .systemRed
        }
    }

    var statusIcon: String {
        switch self {
        case .excellent, .good: "face.smiling"
        case .fair: "face.smiling"
        case .poor: "exclamationmark"
        case .disconnected: "xmark"
        }
    }

    init(from state: NetworkState) {
        guard state.isConnected else {
            self = .disconnected
            return
        }

        let rssi = state.wifi.rssi
        let packetLoss = state.internet.packetLoss
        let latency = state.internet.latency

        if packetLoss > 10 || rssi < -80 {
            self = .poor
        } else if rssi < -70 || latency > 100 || packetLoss > 5 {
            self = .fair
        } else if rssi < -60 {
            self = .good
        } else {
            self = .excellent
        }
    }
}

struct MenuBarIconView: View {
    let quality: ConnectionQuality

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(quality.color))

            Circle()
                .fill(Color(quality.color))
                .frame(width: 6, height: 6)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
                .offset(x: 2, y: 2)
        }
        .frame(width: 22, height: 22)
    }
}

enum MenuBarIconRenderer {
    static func createImage(for quality: ConnectionQuality) -> NSImage {
        let view = MenuBarIconView(quality: quality)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        guard let cgImage = renderer.cgImage else {
            return NSImage(systemSymbolName: "wifi", accessibilityDescription: "WiFi")!
        }

        let image = NSImage(cgImage: cgImage, size: NSSize(width: 22, height: 22))
        image.isTemplate = false
        return image
    }
}

#Preview {
    HStack(spacing: 20) {
        MenuBarIconView(quality: .excellent)
        MenuBarIconView(quality: .good)
        MenuBarIconView(quality: .fair)
        MenuBarIconView(quality: .poor)
        MenuBarIconView(quality: .disconnected)
    }
    .padding()
    .background(.black)
}
