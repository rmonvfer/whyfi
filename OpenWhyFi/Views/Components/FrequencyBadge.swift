//
//  FrequencyBadge.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct FrequencyBadge: View {
    let band: FrequencyBand

    var body: some View {
        Text(band.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.2))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch band {
        case .twoPointFourGHz: .orange
        case .fiveGHz: .blue
        case .sixGHz: .purple
        case .unknown: .gray
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        FrequencyBadge(band: .twoPointFourGHz)
        FrequencyBadge(band: .fiveGHz)
        FrequencyBadge(band: .sixGHz)
    }
    .padding()
}
