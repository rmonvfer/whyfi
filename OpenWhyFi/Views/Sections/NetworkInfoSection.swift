//
//  NetworkInfoSection.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct NetworkInfoSection: View {
    let wifi: WiFiMetrics
    let isConnected: Bool
    var linkRateHistory: [Double] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                StatusDot(color: statusColor)

                if let ssid = wifi.ssid {
                    Text(ssid)
                        .font(.title3)
                        .fontWeight(.semibold)

                    FrequencyBadge(band: wifi.frequencyBand)
                } else {
                    Text("Not Connected")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }

            if isConnected {
                Divider()

                MetricRow(
                    label: "Link Rate",
                    value: "\(Int(wifi.linkRate))",
                    unit: "Mbps",
                    sparklineData: linkRateHistory.isEmpty ? nil : linkRateHistory,
                    color: .primary
                )
            }
        }
    }

    private var statusColor: Color {
        isConnected ? .green : .red
    }
}

#Preview {
    VStack(spacing: 20) {
        NetworkInfoSection(
            wifi: WiFiMetrics(
                ssid: "HomeNetwork",
                bssid: nil,
                rssi: -54,
                noise: -90,
                channel: 36,
                linkRate: 866,
                frequencyBand: .fiveGHz
            ),
            isConnected: true,
            linkRateHistory: [800, 850, 820, 866, 840, 860]
        )

        NetworkInfoSection(
            wifi: .empty,
            isConnected: false
        )
    }
    .padding()
    .frame(width: 340)
    .background(.black)
}
