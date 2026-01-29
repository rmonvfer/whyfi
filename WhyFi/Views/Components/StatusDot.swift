//
//  StatusDot.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct StatusDot: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    HStack(spacing: 16) {
        StatusDot(color: .green)
        StatusDot(color: .yellow)
        StatusDot(color: .red)
    }
    .padding()
}
