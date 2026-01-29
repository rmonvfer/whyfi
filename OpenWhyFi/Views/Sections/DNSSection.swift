//
//  DNSSection.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct DNSSection: View {
    let dns: DNSMetrics
    var lookupHistory: [Double] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "DNS", subtitle: dns.server)

            MetricRow(
                label: "Lookup",
                value: String(format: "%.0f", dns.lookupTime),
                unit: "ms",
                sparklineData: lookupHistory.isEmpty ? nil : lookupHistory,
                color: dns.isWorking ? .green : .red
            )
        }
    }
}

#Preview {
    DNSSection(
        dns: DNSMetrics(server: "8.8.8.8", lookupTime: 25, isWorking: true),
        lookupHistory: [20, 25, 22, 28, 24, 26, 23, 25]
    )
    .padding()
    .frame(width: 340)
    .background(.black)
}
