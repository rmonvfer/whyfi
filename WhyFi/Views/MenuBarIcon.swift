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
        case .fair: "minus"
        case .poor: "chevron.down"
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
    let colorful: Bool

    private let faceSize: CGFloat = 10
    private let cutoutSize: CGFloat = 12

    var body: some View {
        ZStack {
            Image(systemName: "wifi")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(colorful ? Color(quality.color) : Color.primary)
                .mask {
                    if colorful {
                        Rectangle()
                            .overlay(alignment: .bottomTrailing) {
                                Circle()
                                    .frame(width: cutoutSize, height: cutoutSize)
                                    .blendMode(.destinationOut)
                                    .offset(x: 1, y: 1)
                            }
                            .compositingGroup()
                    } else {
                        Rectangle()
                    }
                }

            if colorful {
                SmallFaceIndicator(mood: quality.mood, color: Color(quality.color))
                    .frame(width: faceSize, height: faceSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: -2, y: -2)
            }
        }
        .frame(width: 28, height: 22)
    }
}

enum FaceMood {
    case happy
    case neutral
    case sad
}

extension ConnectionQuality {
    var mood: FaceMood {
        switch self {
        case .excellent, .good: .happy
        case .fair: .neutral
        case .poor, .disconnected: .sad
        }
    }
}

struct SmallFaceIndicator: View {
    let mood: FaceMood
    var color: Color?

    private var faceColor: Color {
        if let color = color {
            return color
        }
        switch mood {
        case .happy: return Color(NSColor.systemGreen)
        case .neutral: return Color(NSColor.systemYellow)
        case .sad: return Color(NSColor.systemRed)
        }
    }

    private var featureColor: Color {
        .black.opacity(0.7)
    }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2

            context.fill(
                Path(ellipseIn: CGRect(x: 0, y: 0, width: size.width, height: size.height)),
                with: .color(faceColor)
            )

            let eyeY = center.y - radius * 0.2
            let eyeRadius: CGFloat = radius * 0.15
            let eyeSpacing = radius * 0.35

            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - eyeSpacing - eyeRadius,
                    y: eyeY - eyeRadius,
                    width: eyeRadius * 2,
                    height: eyeRadius * 2
                )),
                with: .color(featureColor)
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x + eyeSpacing - eyeRadius,
                    y: eyeY - eyeRadius,
                    width: eyeRadius * 2,
                    height: eyeRadius * 2
                )),
                with: .color(featureColor)
            )

            var mouthPath = Path()
            let mouthY = center.y + radius * 0.25
            let mouthWidth = radius * 0.5

            switch mood {
            case .happy:
                mouthPath.move(to: CGPoint(x: center.x - mouthWidth, y: mouthY))
                mouthPath.addQuadCurve(
                    to: CGPoint(x: center.x + mouthWidth, y: mouthY),
                    control: CGPoint(x: center.x, y: mouthY + radius * 0.4)
                )
            case .neutral:
                mouthPath.move(to: CGPoint(x: center.x - mouthWidth, y: mouthY + radius * 0.1))
                mouthPath.addLine(to: CGPoint(x: center.x + mouthWidth, y: mouthY + radius * 0.1))
            case .sad:
                mouthPath.move(to: CGPoint(x: center.x - mouthWidth, y: mouthY + radius * 0.3))
                mouthPath.addQuadCurve(
                    to: CGPoint(x: center.x + mouthWidth, y: mouthY + radius * 0.3),
                    control: CGPoint(x: center.x, y: mouthY - radius * 0.1)
                )
            }

            context.stroke(
                mouthPath,
                with: .color(featureColor),
                lineWidth: 1.2
            )
        }
    }
}

struct MenuBarMetricValue {
    let metric: MenuBarMetric
    let value: String
    let color: Color

    static func from(metric: MenuBarMetric, state: NetworkState) -> MenuBarMetricValue? {
        guard metric != .none else { return nil }

        let value: String
        let color: Color

        switch metric {
        case .none:
            return nil
        case .rssi:
            value = "\(state.wifi.rssi)"
            color = SignalQuality(rssi: state.wifi.rssi).color
        case .noise:
            value = "\(state.wifi.noise)"
            color = state.wifi.noise <= -80 ? .green : .orange
        case .linkRate:
            value = "\(Int(state.wifi.linkRate))"
            color = state.wifi.linkRate >= 100 ? .green : .orange
        case .routerLatency:
            value = String(format: "%.0f", state.router.latency)
            color = LatencyQuality(latency: state.router.latency).color
        case .internetLatency:
            value = String(format: "%.0f", state.internet.latency)
            color = LatencyQuality(latency: state.internet.latency).color
        case .packetLoss:
            value = String(format: "%.0f", state.internet.packetLoss)
            color = state.internet.packetLoss <= 1 ? .green : (state.internet.packetLoss <= 5 ? .yellow : .red)
        }

        return MenuBarMetricValue(metric: metric, value: value, color: color)
    }
}

struct MenuBarWithMetricsView: View {
    let quality: ConnectionQuality
    let colorful: Bool
    let metrics: [MenuBarMetricValue]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { index, metric in
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(metric.metric.icon)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(colorful ? metric.color.opacity(0.7) : Color.primary.opacity(0.7))
                    Text(metric.value)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(colorful ? metric.color : Color.primary)
                    Text(metric.metric.unit)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(colorful ? metric.color.opacity(0.7) : Color.primary.opacity(0.7))
                }
                if index < metrics.count - 1 {
                    Text("·")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 22, alignment: .bottom)
        .padding(.bottom, 2)
    }
}

enum MenuBarIconRenderer {
    static func createImage(for quality: ConnectionQuality, colorful: Bool = true) -> NSImage {
        let view = MenuBarIconView(quality: quality, colorful: colorful)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        guard let cgImage = renderer.cgImage else {
            return NSImage(systemSymbolName: "wifi", accessibilityDescription: "WiFi")!
        }

        let image = NSImage(cgImage: cgImage, size: NSSize(width: 28, height: 22))
        image.isTemplate = !colorful
        return image
    }

    static func createImageWithMetrics(
        for quality: ConnectionQuality,
        colorful: Bool = true,
        metrics: [MenuBarMetricValue]
    ) -> NSImage {
        let view = MenuBarWithMetricsView(quality: quality, colorful: colorful, metrics: metrics)
            .fixedSize()
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        guard let cgImage = renderer.cgImage else {
            return createImage(for: quality, colorful: colorful)
        }

        let width = CGFloat(cgImage.width) / 2.0
        let image = NSImage(cgImage: cgImage, size: NSSize(width: width, height: 22))
        image.isTemplate = false
        return image
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Colorful Icons")
            .foregroundStyle(.white)
        HStack(spacing: 20) {
            MenuBarIconView(quality: .excellent, colorful: true)
            MenuBarIconView(quality: .good, colorful: true)
            MenuBarIconView(quality: .fair, colorful: true)
            MenuBarIconView(quality: .poor, colorful: true)
            MenuBarIconView(quality: .disconnected, colorful: true)
        }
        Text("Monochrome Icons")
            .foregroundStyle(.white)
        HStack(spacing: 20) {
            MenuBarIconView(quality: .excellent, colorful: false)
            MenuBarIconView(quality: .good, colorful: false)
            MenuBarIconView(quality: .fair, colorful: false)
            MenuBarIconView(quality: .poor, colorful: false)
            MenuBarIconView(quality: .disconnected, colorful: false)
        }
        Text("Face Indicators (large)")
            .foregroundStyle(.white)
        HStack(spacing: 20) {
            SmallFaceIndicator(mood: .happy)
                .frame(width: 30, height: 30)
            SmallFaceIndicator(mood: .neutral)
                .frame(width: 30, height: 30)
            SmallFaceIndicator(mood: .sad)
                .frame(width: 30, height: 30)
        }
    }
    .padding()
    .background(.black)
}
