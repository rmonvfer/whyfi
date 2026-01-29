//
//  SectionHeader.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            if let subtitle = subtitle {
                Text("·")
                    .foregroundStyle(.tertiary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SectionHeader(title: "Router")
        SectionHeader(title: "Internet", subtitle: "Connected to 1.1.1.1")
        SectionHeader(title: "DNS", subtitle: "Router assigned (192.168.1.1)")
    }
    .padding()
    .background(.black)
}
