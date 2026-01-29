//
//  MetricHistory.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

struct MetricHistory<T: Sendable>: Sendable {
    private var buffer: [T]
    private let capacity: Int

    init(capacity: Int = 60) {
        self.capacity = capacity
        self.buffer = []
        self.buffer.reserveCapacity(capacity)
    }

    mutating func append(_ value: T) {
        if buffer.count >= capacity {
            buffer.removeFirst()
        }
        buffer.append(value)
    }

    var values: [T] {
        buffer
    }

    var count: Int {
        buffer.count
    }

    var isEmpty: Bool {
        buffer.isEmpty
    }

    var latest: T? {
        buffer.last
    }
}

extension MetricHistory where T == Double {
    var average: Double {
        guard !buffer.isEmpty else { return 0 }
        return buffer.reduce(0, +) / Double(buffer.count)
    }

    var min: Double {
        buffer.min() ?? 0
    }

    var max: Double {
        buffer.max() ?? 0
    }
}
