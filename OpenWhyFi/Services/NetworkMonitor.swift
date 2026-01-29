//
//  NetworkMonitor.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class NetworkMonitor {
    private(set) var state: NetworkState = .empty
    private(set) var rssiHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var noiseHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var linkRateHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var routerLatencyHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var routerJitterHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var routerLossHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var internetLatencyHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var internetJitterHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var internetLossHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)
    private(set) var dnsLookupHistory = MetricHistory<Double>(capacity: Constants.historyCapacity)

    private let wifiService = WiFiService()
    private let gatewayResolver = GatewayResolver()
    private let pingService = PingService()
    private let dnsService = DNSService()
    private let speedTestService = SpeedTestService()

    private var pollingTask: Task<Void, Never>?

    func startMonitoring() {
        guard pollingTask == nil else { return }

        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.collectMetrics()
                try? await Task.sleep(for: .seconds(Constants.pollingInterval))
            }
        }
    }

    func stopMonitoring() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func runSpeedTest() async {
        state.speedTest.isRunning = true
        let results = await speedTestService.runFullTest()
        state.speedTest = results
    }

    private func collectMetrics() async {
        let wifi = await wifiService.getCurrentMetrics()
        let isConnected = wifi.ssid != nil

        if isConnected {
            rssiHistory.append(Double(wifi.rssi))
            noiseHistory.append(Double(wifi.noise))
            linkRateHistory.append(wifi.linkRate)
        }

        var gatewayIP = state.gatewayIP
        if gatewayIP == nil || !isConnected {
            gatewayIP = await gatewayResolver.getDefaultGateway()
        }

        async let internetPing = pingService.ping(host: Constants.internetHost)
        async let dnsMetrics = dnsService.measureLookupTime()

        let router: PingMetrics
        if let ip = gatewayIP {
            router = await pingService.ping(host: ip)
        } else {
            router = .empty(host: "Gateway")
        }

        let (internet, dns) = await (internetPing, dnsMetrics)

        if router.isReachable {
            routerLatencyHistory.append(router.latency)
            routerJitterHistory.append(router.jitter)
            routerLossHistory.append(router.packetLoss)
        }
        if internet.isReachable {
            internetLatencyHistory.append(internet.latency)
            internetJitterHistory.append(internet.jitter)
            internetLossHistory.append(internet.packetLoss)
        }
        if dns.isWorking {
            dnsLookupHistory.append(dns.lookupTime)
        }

        state = NetworkState(
            wifi: wifi,
            router: router,
            internet: internet,
            dns: dns,
            speedTest: state.speedTest,
            isConnected: isConnected,
            gatewayIP: gatewayIP
        )
    }
}
