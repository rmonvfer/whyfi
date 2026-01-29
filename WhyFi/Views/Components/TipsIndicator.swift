//
//  TipsIndicator.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct TipsBadge: View {
    let tips: [NetworkTip]
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        if !tips.isEmpty {
            Button(action: onTap) {
                HStack(spacing: 4) {
                    Image(systemName: worstSeverity.icon)
                        .font(.caption2)

                    if tips.count == 1 {
                        Text(tips[0].title)
                            .font(.caption2)
                    } else {
                        Text("\(tips.count)")
                            .font(.caption2)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundStyle(worstSeverity.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(worstSeverity.color.opacity(0.15))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var worstSeverity: NetworkTip.Severity {
        tips.first?.severity ?? .info
    }
}

struct TipsExpandedView: View {
    let tips: [NetworkTip]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tips) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: tip.severity.icon)
                        .font(.caption)
                        .foregroundStyle(tip.severity.color)
                        .frame(width: 14)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(tip.severity.color)

                        Text(tip.message)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TipsIndicator: View {
    let tips: [NetworkTip]
    @State private var isExpanded = false

    var body: some View {
        TipsBadge(tips: tips, isExpanded: isExpanded) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TipsBadge(tips: [
            NetworkTip(title: "Weak Signal", message: "Move closer.", severity: .warning)
        ], isExpanded: false, onTap: {})

        TipsBadge(tips: [
            NetworkTip(title: "Critical", message: "Bad.", severity: .critical),
            NetworkTip(title: "Warning", message: "Meh.", severity: .warning),
        ], isExpanded: false, onTap: {})

        TipsExpandedView(tips: [
            NetworkTip(title: "Very Weak Signal", message: "Move closer to router.", severity: .critical),
            NetworkTip(title: "High Latency", message: "May affect video calls.", severity: .warning),
        ])
    }
    .padding()
    .frame(width: 360)
    .background(.black)
}
