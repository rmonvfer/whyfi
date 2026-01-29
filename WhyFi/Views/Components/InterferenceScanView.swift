//
//  InterferenceScanView.swift
//  WhyFi
//
//  Created by Ramon on 1/29/26.
//

import SwiftUI

struct InterferenceScanView: View {
    let result: InterferenceScanResult
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Interference Scan")
                    .font(.headline)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if let recommendation = result.recommendation {
                RecommendationBanner(recommendation: recommendation)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Connection")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Label("Channel \(result.currentChannel)", systemImage: "antenna.radiowaves.left.and.right")
                    Spacer()
                    Text(result.currentBand.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(result.currentBand == .fiveGHz ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
                .font(.callout)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Networks on Your Channel")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if result.networksOnSameChannel.isEmpty {
                    Text("No competing networks detected")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    ForEach(result.networksOnSameChannel.prefix(5)) { network in
                        HStack {
                            Text(network.ssid)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text("\(network.rssi) dBm")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(network.signalDescription)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(signalColor(for: network.rssi).opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    if result.networksOnSameChannel.count > 5 {
                        Text("+\(result.networksOnSameChannel.count - 5) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Band Comparison")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    BandComparisonPill(
                        band: "2.4 GHz",
                        count: result.twoGHzNetworkCount,
                        isCurrent: result.currentBand == .twoPointFourGHz
                    )
                    BandComparisonPill(
                        band: "5 GHz",
                        count: result.fiveGHzNetworkCount,
                        isCurrent: result.currentBand == .fiveGHz
                    )
                }
            }

            Divider()

            ChannelCongestionChart(
                congestion: result.channelCongestion.filter { $0.band == result.currentBand },
                currentChannel: result.currentChannel
            )

            Text("Scanned at \(result.scanTime.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(width: 300)
    }

    private func signalColor(for rssi: Int) -> Color {
        switch rssi {
        case _ where rssi >= -50: .green
        case -60 ..< -50: .green
        case -70 ..< -60: .yellow
        case -80 ..< -70: .orange
        default: .red
        }
    }
}

struct RecommendationBanner: View {
    let recommendation: InterferenceRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: recommendation.actionable ? "lightbulb.fill" : "info.circle.fill")
                    .foregroundStyle(recommendation.actionable ? .yellow : .blue)
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Text(recommendation.message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(recommendation.actionable ? Color.yellow.opacity(0.1) : Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct BandComparisonPill: View {
    let band: String
    let count: Int
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(band)
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("networks")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isCurrent ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrent ? Color.accentColor : Color.clear, lineWidth: 1)
        )
    }
}

struct ChannelCongestionChart: View {
    let congestion: [ChannelCongestion]
    let currentChannel: Int

    private var maxCount: Int {
        max(congestion.map(\.networkCount).max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Channel Congestion")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(congestion.prefix(11)) { channel in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(channel.isCurrentChannel ? Color.accentColor : congestionColor(channel.networkCount))
                            .frame(width: 16, height: max(4, CGFloat(channel.networkCount) / CGFloat(maxCount) * 40))

                        Text("\(channel.channel)")
                            .font(.system(size: 8))
                            .foregroundStyle(channel.isCurrentChannel ? .primary : .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func congestionColor(_ count: Int) -> Color {
        switch count {
        case 0: .gray.opacity(0.3)
        case 1: .green
        case 2...3: .yellow
        case 4...6: .orange
        default: .red
        }
    }
}

#Preview {
    InterferenceScanView(
        result: InterferenceScanResult(
            currentChannel: 6,
            currentBand: .twoPointFourGHz,
            nearbyNetworks: [
                NearbyNetwork(ssid: "Neighbor-WiFi", bssid: "aa:bb:cc:dd:ee:ff", channel: 6, rssi: -45, band: .twoPointFourGHz),
                NearbyNetwork(ssid: "HomeNetwork", bssid: "11:22:33:44:55:66", channel: 6, rssi: -52, band: .twoPointFourGHz),
                NearbyNetwork(ssid: "Apartment-301", bssid: "ff:ee:dd:cc:bb:aa", channel: 6, rssi: -68, band: .twoPointFourGHz),
            ],
            channelCongestion: [
                ChannelCongestion(id: 1, channel: 1, band: .twoPointFourGHz, networkCount: 2, isCurrentChannel: false),
                ChannelCongestion(id: 6, channel: 6, band: .twoPointFourGHz, networkCount: 5, isCurrentChannel: true),
                ChannelCongestion(id: 11, channel: 11, band: .twoPointFourGHz, networkCount: 1, isCurrentChannel: false),
            ],
            recommendation: InterferenceRecommendation(
                title: "Switch to 5 GHz",
                message: "5 GHz band has 3 networks vs 15 on 2.4 GHz. Look for your network's 5G variant.",
                actionable: true
            ),
            scanTime: Date()
        ),
        onDismiss: {}
    )
    .background(.black)
}
