//
//  PopupPanelView.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct PopupPanelView: View {
    @Environment(NetworkMonitor.self) private var monitor
    @Environment(LocationManager.self) private var locationManager

    private var currentTips: [NetworkTip] {
        NetworkTips.analyze(
            wifi: monitor.state.wifi,
            router: monitor.state.router,
            internet: monitor.state.internet
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderSection()

            Divider()

            if !locationManager.isAuthorized {
                LocationPermissionView(onRequest: {
                    locationManager.requestAuthorization()
                })
            } else if monitor.state.isConnected {
                NetworkInfoSection(
                    wifi: monitor.state.wifi,
                    isConnected: monitor.state.isConnected,
                    linkRateHistory: monitor.linkRateHistory.values,
                    tips: currentTips,
                    hasCaptivePortal: monitor.captivePortalStatus.isDetected,
                    captivePortalURL: monitor.captivePortalLoginURL
                )

                WiFiMetricsSection(
                    wifi: monitor.state.wifi,
                    rssiHistory: monitor.rssiHistory.values,
                    noiseHistory: monitor.noiseHistory.values
                )

                Divider()

                RouterSection(
                    router: monitor.state.router,
                    gatewayIP: monitor.state.gatewayIP,
                    latencyHistory: monitor.routerLatencyHistory.values,
                    jitterHistory: monitor.routerJitterHistory.values,
                    lossHistory: monitor.routerLossHistory.values
                )

                Divider()

                InternetSection(
                    internet: monitor.state.internet,
                    latencyHistory: monitor.internetLatencyHistory.values,
                    jitterHistory: monitor.internetJitterHistory.values,
                    lossHistory: monitor.internetLossHistory.values
                )

                Divider()

                DNSSection(
                    dns: monitor.state.dns,
                    lookupHistory: monitor.dnsLookupHistory.values
                )

                Divider()

                SpeedTestSection(
                    speedTest: monitor.state.speedTest,
                    onRunTest: {
                        Task {
                            await monitor.runSpeedTest()
                        }
                    }
                )
            } else {
                NetworkInfoSection(
                    wifi: monitor.state.wifi,
                    isConnected: monitor.state.isConnected
                )
                DisconnectedView()
            }

            Divider()

            Button("Quit WhyFi") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
        }
        .padding()
        .frame(width: Constants.panelWidth)
    }
}

struct LocationPermissionView: View {
    let onRequest: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Location Permission Required")
                .font(.headline)

            Text("macOS requires location access to read WiFi network information. Your location data is never collected or stored.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Grant Location Access") {
                onRequest()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct DisconnectedView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No WiFi Connection")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Connect to a WiFi network to see diagnostics")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    PopupPanelView()
        .environment(NetworkMonitor())
        .environment(LocationManager())
}
