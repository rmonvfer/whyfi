//
//  NetworkInfoSection.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct NetworkInfoSection: View {
    let wifi: WiFiMetrics
    let isConnected: Bool
    var linkRateHistory: [Double] = []
    var tips: [NetworkTip] = []
    var hasCaptivePortal: Bool = false
    var captivePortalURL: URL? = nil

    @State private var tipsExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                StatusDot(color: statusColor)

                if let ssid = wifi.ssid {
                    Text(ssid)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    FrequencyBadge(band: wifi.frequencyBand)

                    Spacer()

                    if !hasCaptivePortal && !tips.isEmpty {
                        TipsBadge(tips: tips, isExpanded: tipsExpanded) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                tipsExpanded.toggle()
                            }
                        }
                    }
                } else {
                    Text("Not Connected")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }

            if hasCaptivePortal {
                CaptivePortalBanner(loginURL: captivePortalURL)
            } else if tipsExpanded && !tips.isEmpty {
                TipsExpandedView(tips: tips)
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
