//
//  WiFiMetricsSection.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct WiFiMetricsSection: View {
    let wifi: WiFiMetrics
    let rssiHistory: [Double]
    let noiseHistory: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MetricRow(
                label: "Signal",
                value: "\(wifi.rssi)",
                unit: "dBm",
                sparklineData: rssiHistory,
                color: SignalQuality(rssi: wifi.rssi).color
            )

            MetricRow(
                label: "Noise",
                value: "\(wifi.noise)",
                unit: "dBm",
                sparklineData: noiseHistory,
                color: noiseColor
            )
        }
    }

    private var noiseColor: Color {
        wifi.noise <= -80 ? .green : .orange
    }
}

#Preview {
    WiFiMetricsSection(
        wifi: WiFiMetrics(
            ssid: "Test",
            bssid: nil,
            rssi: -54,
            noise: -90,
            channel: 36,
            linkRate: 866,
            frequencyBand: .fiveGHz
        ),
        rssiHistory: [-50, -52, -48, -54, -51, -53, -49, -55],
        noiseHistory: [-88, -90, -89, -91, -90, -88, -92, -90]
    )
    .padding()
    .frame(width: 340)
    .background(.black)
}
