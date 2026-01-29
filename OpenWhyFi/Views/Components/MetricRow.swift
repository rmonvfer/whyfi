//
//  MetricRow.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct MetricRow: View {
    let label: String
    let value: String
    let unit: String
    var sparklineData: [Double]? = nil
    var color: Color = .green

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                    .monospaced()

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(color)
                    .monospaced()
            }
            .fixedSize()

            if let data = sparklineData, !data.isEmpty {
                SparklineChart(data: data, color: color, height: 14)
                    .frame(width: 140)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    VStack(spacing: 12) {
        MetricRow(
            label: "Signal",
            value: "-54",
            unit: "dBm",
            sparklineData: [-50, -52, -48, -54, -51, -53, -49, -55],
            color: .green
        )
        MetricRow(
            label: "Latency",
            value: "12.5",
            unit: "ms",
            color: .orange
        )
    }
    .padding()
    .frame(width: 340)
    .background(.black)
}
