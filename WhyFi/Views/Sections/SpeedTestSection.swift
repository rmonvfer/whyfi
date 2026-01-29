//
//  SpeedTestSection.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct SpeedTestSection: View {
    let speedTest: SpeedTestMetrics
    let onRunTest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Speed Test", subtitle: "Cloudflare")

            if speedTest.isRunning {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Testing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if speedTest.lastTestTime != nil {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", speedTest.downloadSpeed))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("Mbps")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", speedTest.uploadSpeed))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("Mbps")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("Retest") {
                        onRunTest()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                Button {
                    onRunTest()
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Run Speed Test")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeedTestSection(
            speedTest: .empty,
            onRunTest: {}
        )

        SpeedTestSection(
            speedTest: SpeedTestMetrics(downloadSpeed: 63.8, uploadSpeed: 62.3, isRunning: false, lastTestTime: Date()),
            onRunTest: {}
        )
    }
    .padding()
    .frame(width: 340)
    .background(.black)
}
