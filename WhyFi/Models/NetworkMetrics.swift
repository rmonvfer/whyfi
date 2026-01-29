//
//  NetworkMetrics.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

struct WiFiMetrics: Sendable {
    var ssid: String?
    var bssid: String?
    var rssi: Int
    var noise: Int
    var channel: Int
    var linkRate: Double
    var frequencyBand: FrequencyBand

    var snr: Int {
        rssi - noise
    }

    static let empty = WiFiMetrics(
        ssid: nil,
        bssid: nil,
        rssi: -100,
        noise: -100,
        channel: 0,
        linkRate: 0,
        frequencyBand: .unknown
    )
}

enum FrequencyBand: Sendable, Equatable {
    case twoPointFourGHz
    case fiveGHz
    case sixGHz
    case unknown

    var displayName: String {
        switch self {
        case .twoPointFourGHz: "2.4 GHz"
        case .fiveGHz: "5 GHz"
        case .sixGHz: "6 GHz"
        case .unknown: "Unknown"
        }
    }

    nonisolated init(channel: Int) {
        if channel >= 1 && channel <= 14 {
            self = .twoPointFourGHz
        } else if channel >= 36 && channel <= 177 {
            self = .fiveGHz
        } else if channel >= 1 && channel <= 233 {
            self = .sixGHz
        } else {
            self = .unknown
        }
    }
}

struct PingMetrics: Sendable {
    var host: String
    var latency: Double
    var jitter: Double
    var packetLoss: Double
    var isReachable: Bool

    nonisolated static func empty(host: String) -> PingMetrics {
        PingMetrics(host: host, latency: 0, jitter: 0, packetLoss: 100, isReachable: false)
    }
}

struct DNSMetrics: Sendable {
    var server: String
    var lookupTime: Double
    var isWorking: Bool

    static let empty = DNSMetrics(server: "Unknown", lookupTime: 0, isWorking: false)
}

struct SpeedTestMetrics: Sendable {
    var downloadSpeed: Double
    var uploadSpeed: Double
    var isRunning: Bool
    var lastTestTime: Date?

    static let empty = SpeedTestMetrics(downloadSpeed: 0, uploadSpeed: 0, isRunning: false, lastTestTime: nil)
}

struct NetworkState: Sendable {
    var wifi: WiFiMetrics
    var router: PingMetrics
    var internet: PingMetrics
    var dns: DNSMetrics
    var speedTest: SpeedTestMetrics
    var isConnected: Bool
    var gatewayIP: String?

    static let empty = NetworkState(
        wifi: .empty,
        router: .empty(host: "Gateway"),
        internet: .empty(host: "1.1.1.1"),
        dns: .empty,
        speedTest: .empty,
        isConnected: false,
        gatewayIP: nil
    )
}
