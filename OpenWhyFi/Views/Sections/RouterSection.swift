//
//  RouterSection.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct RouterSection: View {
    let router: PingMetrics
    let gatewayIP: String?
    let latencyHistory: [Double]
    var jitterHistory: [Double] = []
    var lossHistory: [Double] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Router", subtitle: gatewayIP)

            MetricRow(
                label: "Ping",
                value: String(format: "%.0f", router.latency),
                unit: "ms",
                sparklineData: latencyHistory,
                color: latencyColor
            )

            MetricRow(
                label: "Jitter",
                value: String(format: "%.1f", router.jitter),
                unit: "ms",
                sparklineData: jitterHistory.isEmpty ? nil : jitterHistory,
                color: jitterColor
            )

            MetricRow(
                label: "Loss",
                value: String(format: "%.0f", router.packetLoss),
                unit: "%",
                sparklineData: lossHistory.isEmpty ? nil : lossHistory,
                color: router.packetLoss > 0 ? .orange : .green
            )
        }
    }

    private var latencyColor: Color {
        LatencyQuality(latency: router.latency).color
    }

    private var jitterColor: Color {
        router.jitter < 5 ? .green : (router.jitter < 20 ? .yellow : .orange)
    }
}

#Preview {
    RouterSection(
        router: PingMetrics(host: "192.168.1.1", latency: 2.5, jitter: 0.8, packetLoss: 0, isReachable: true),
        gatewayIP: "192.168.1.1",
        latencyHistory: [2.1, 2.5, 2.3, 2.8, 2.4, 2.6, 2.2, 2.5]
    )
    .padding()
    .frame(width: 340)
    .background(.black)
}
