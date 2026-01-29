//
//  InternetSection.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct InternetSection: View {
    let internet: PingMetrics
    let latencyHistory: [Double]
    var jitterHistory: [Double] = []
    var lossHistory: [Double] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Internet", subtitle: "Connected to \(Constants.internetHost)")

            MetricRow(
                label: "Ping",
                value: String(format: "%.0f", internet.latency),
                unit: "ms",
                sparklineData: latencyHistory,
                color: latencyColor
            )

            MetricRow(
                label: "Jitter",
                value: String(format: "%.1f", internet.jitter),
                unit: "ms",
                sparklineData: jitterHistory.isEmpty ? nil : jitterHistory,
                color: jitterColor
            )

            MetricRow(
                label: "Loss",
                value: String(format: "%.0f", internet.packetLoss),
                unit: "%",
                sparklineData: lossHistory.isEmpty ? nil : lossHistory,
                color: internet.packetLoss > 0 ? .orange : .green
            )
        }
    }

    private var latencyColor: Color {
        LatencyQuality(latency: internet.latency).color
    }

    private var jitterColor: Color {
        internet.jitter < 10 ? .green : (internet.jitter < 30 ? .yellow : .orange)
    }
}

#Preview {
    InternetSection(
        internet: PingMetrics(host: "1.1.1.1", latency: 15.2, jitter: 2.1, packetLoss: 0, isReachable: true),
        latencyHistory: [14.5, 15.2, 14.8, 16.1, 15.0, 14.9, 15.3, 15.2]
    )
    .padding()
    .frame(width: 340)
    .background(.black)
}
