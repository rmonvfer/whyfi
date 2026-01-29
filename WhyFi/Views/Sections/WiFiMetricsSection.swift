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

    @State private var isScanning = false
    @State private var scanResult: InterferenceScanResult?
    @State private var showingScanResults = false

    private let scanner = InterferenceScanner()

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

            Button {
                Task {
                    isScanning = true
                    scanResult = await scanner.scan()
                    isScanning = false
                    if scanResult != nil {
                        showingScanResults = true
                    }
                }
            } label: {
                HStack {
                    ZStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .opacity(isScanning ? 0 : 1)
                        if isScanning {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                    .frame(width: 16, height: 16)
                    Text("Scan for Interference")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(isScanning)
            .popover(isPresented: $showingScanResults) {
                if let result = scanResult {
                    InterferenceScanView(result: result) {
                        showingScanResults = false
                    }
                }
            }
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
