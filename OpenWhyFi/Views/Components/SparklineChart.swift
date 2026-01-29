//
//  SparklineChart.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Charts
import SwiftUI

struct SparklineChart: View {
    let data: [Double]
    var color: Color = .blue
    var height: CGFloat = 24

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color.opacity(0.2).gradient)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: height)
    }
}

#Preview {
    SparklineChart(
        data: [10, 15, 12, 18, 14, 20, 16, 22, 19, 25],
        color: .green
    )
    .frame(width: 80)
    .padding()
}
