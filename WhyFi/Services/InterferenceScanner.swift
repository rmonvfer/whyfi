//
//  InterferenceScanner.swift
//  WhyFi
//
//  Created by Ramon on 1/29/26.
//

import CoreWLAN
import Foundation

struct NearbyNetwork: Identifiable, Sendable {
    let id = UUID()
    let ssid: String
    let bssid: String
    let channel: Int
    let rssi: Int
    let band: FrequencyBand

    var signalDescription: String {
        switch rssi {
        case _ where rssi >= -50: "Strong"
        case -60 ..< -50: "Good"
        case -70 ..< -60: "Fair"
        case -80 ..< -70: "Weak"
        default: "Very Weak"
        }
    }
}

struct ChannelCongestion: Identifiable, Sendable {
    let id: Int
    let channel: Int
    let band: FrequencyBand
    let networkCount: Int
    let isCurrentChannel: Bool

    var congestionLevel: CongestionLevel {
        switch networkCount {
        case 0: .empty
        case 1: .low
        case 2...3: .moderate
        case 4...6: .high
        default: .veryHigh
        }
    }

    enum CongestionLevel: String {
        case empty = "Empty"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }
}

struct InterferenceScanResult: Sendable {
    let currentChannel: Int
    let currentBand: FrequencyBand
    let nearbyNetworks: [NearbyNetwork]
    let channelCongestion: [ChannelCongestion]
    let recommendation: InterferenceRecommendation?
    let scanTime: Date

    var networksOnSameChannel: [NearbyNetwork] {
        nearbyNetworks.filter { $0.channel == currentChannel && $0.band == currentBand }
    }

    var twoGHzNetworkCount: Int {
        nearbyNetworks.filter { $0.band == .twoPointFourGHz }.count
    }

    var fiveGHzNetworkCount: Int {
        nearbyNetworks.filter { $0.band == .fiveGHz }.count
    }
}

struct InterferenceRecommendation: Sendable {
    let title: String
    let message: String
    let actionable: Bool
}

actor InterferenceScanner {
    private let wifiClient = CWWiFiClient.shared()

    func scan() async -> InterferenceScanResult? {
        guard let interface = wifiClient.interface() else {
            return nil
        }

        let currentChannel = interface.wlanChannel()?.channelNumber ?? 0
        let currentBand = FrequencyBand(channel: currentChannel)

        do {
            let networks = try interface.scanForNetworks(withName: nil)

            let nearbyNetworks: [NearbyNetwork] = networks.compactMap { network in
                guard let ssid = network.ssid, !ssid.isEmpty else { return nil }
                let channel = network.wlanChannel?.channelNumber ?? 0
                return NearbyNetwork(
                    ssid: ssid,
                    bssid: network.bssid ?? "",
                    channel: channel,
                    rssi: network.rssiValue,
                    band: FrequencyBand(channel: channel)
                )
            }.sorted { $0.rssi > $1.rssi }

            let channelCongestion = calculateChannelCongestion(
                networks: nearbyNetworks,
                currentChannel: currentChannel,
                currentBand: currentBand
            )

            let recommendation = generateRecommendation(
                currentChannel: currentChannel,
                currentBand: currentBand,
                nearbyNetworks: nearbyNetworks,
                channelCongestion: channelCongestion
            )

            return InterferenceScanResult(
                currentChannel: currentChannel,
                currentBand: currentBand,
                nearbyNetworks: nearbyNetworks,
                channelCongestion: channelCongestion,
                recommendation: recommendation,
                scanTime: Date()
            )
        } catch {
            print("Failed to scan for networks: \(error)")
            return nil
        }
    }

    private func calculateChannelCongestion(
        networks: [NearbyNetwork],
        currentChannel: Int,
        currentBand: FrequencyBand
    ) -> [ChannelCongestion] {
        var congestion: [ChannelCongestion] = []

        let twoGHzChannels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        for channel in twoGHzChannels {
            let count = networks.filter {
                $0.band == .twoPointFourGHz && overlapsChannel(networkChannel: $0.channel, targetChannel: channel)
            }.count
            congestion.append(ChannelCongestion(
                id: channel,
                channel: channel,
                band: .twoPointFourGHz,
                networkCount: count,
                isCurrentChannel: channel == currentChannel && currentBand == .twoPointFourGHz
            ))
        }

        let fiveGHzChannels = [36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165]
        for channel in fiveGHzChannels {
            let count = networks.filter { $0.channel == channel && $0.band == .fiveGHz }.count
            if count > 0 || channel == currentChannel {
                congestion.append(ChannelCongestion(
                    id: 100 + channel,
                    channel: channel,
                    band: .fiveGHz,
                    networkCount: count,
                    isCurrentChannel: channel == currentChannel && currentBand == .fiveGHz
                ))
            }
        }

        return congestion
    }

    private func overlapsChannel(networkChannel: Int, targetChannel: Int) -> Bool {
        guard networkChannel >= 1 && networkChannel <= 11 else { return false }
        guard targetChannel >= 1 && targetChannel <= 11 else { return false }
        return abs(networkChannel - targetChannel) < 5
    }

    private func generateRecommendation(
        currentChannel: Int,
        currentBand: FrequencyBand,
        nearbyNetworks: [NearbyNetwork],
        channelCongestion: [ChannelCongestion]
    ) -> InterferenceRecommendation? {
        let sameChannelCount = nearbyNetworks.filter {
            $0.channel == currentChannel && $0.band == currentBand
        }.count

        let twoGHzCount = nearbyNetworks.filter { $0.band == .twoPointFourGHz }.count
        let fiveGHzCount = nearbyNetworks.filter { $0.band == .fiveGHz }.count

        if currentBand == .twoPointFourGHz && fiveGHzCount < twoGHzCount / 2 {
            return InterferenceRecommendation(
                title: "Switch to 5 GHz",
                message: "5 GHz band has \(fiveGHzCount) networks vs \(twoGHzCount) on 2.4 GHz. Look for your network's 5G variant (often named \"YourNetwork-5G\" or \"YourNetwork_5GHz\").",
                actionable: true
            )
        }

        if sameChannelCount >= 3 {
            let strongCompetitors = nearbyNetworks.filter {
                $0.channel == currentChannel && $0.band == currentBand && $0.rssi > -60
            }
            if !strongCompetitors.isEmpty {
                let names = strongCompetitors.prefix(2).map { "\"\($0.ssid)\"" }.joined(separator: ", ")
                return InterferenceRecommendation(
                    title: "Channel Congestion",
                    message: "\(sameChannelCount) networks share your channel including strong signals from \(names). If possible, switch to 5 GHz.",
                    actionable: false
                )
            }
            return InterferenceRecommendation(
                title: "Crowded Channel",
                message: "\(sameChannelCount) networks are competing on channel \(currentChannel). This may cause slowdowns during peak usage.",
                actionable: false
            )
        }

        if currentBand == .twoPointFourGHz {
            let nonOverlapping = [1, 6, 11]
            if !nonOverlapping.contains(currentChannel) {
                return InterferenceRecommendation(
                    title: "Suboptimal Channel",
                    message: "Channel \(currentChannel) overlaps with adjacent channels. Channels 1, 6, or 11 are recommended for 2.4 GHz.",
                    actionable: false
                )
            }
        }

        return nil
    }
}
