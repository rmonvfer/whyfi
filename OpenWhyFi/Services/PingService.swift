//
//  PingService.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

actor PingService {
    private let defaultPingCount = 3

    func ping(host: String, count: Int? = nil) async -> PingMetrics {
        let pingCount: Int
        if let count = count {
            pingCount = count
        } else {
            pingCount = defaultPingCount
        }
        return await withCheckedContinuation { continuation in
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/sbin/ping")
            process.arguments = ["-c", "\(pingCount)", "-W", "2000", host]
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice

            do {
                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: data, encoding: .utf8) else {
                    continuation.resume(returning: PingMetrics.empty(host: host))
                    return
                }

                let metrics = parsePingOutput(output, host: host)
                continuation.resume(returning: metrics)
            } catch {
                continuation.resume(returning: PingMetrics.empty(host: host))
            }
        }
    }

    private func parsePingOutput(_ output: String, host: String) -> PingMetrics {
        var latency: Double = 0
        var jitter: Double = 0
        var packetLoss: Double = 100
        var isReachable = false

        let lines = output.components(separatedBy: "\n")

        for line in lines {
            if line.contains("packet loss") {
                if let lossMatch = line.range(of: #"(\d+(?:\.\d+)?)% packet loss"#, options: .regularExpression) {
                    let lossStr = String(line[lossMatch]).replacingOccurrences(of: "% packet loss", with: "")
                    packetLoss = Double(lossStr) ?? 100
                    isReachable = packetLoss < 100
                }
            }

            if line.contains("round-trip") || line.contains("rtt") {
                let pattern = #"= ([\d.]+)/([\d.]+)/([\d.]+)/([\d.]+)"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    if let avgRange = Range(match.range(at: 2), in: line) {
                        latency = Double(line[avgRange]) ?? 0
                    }
                    if let stddevRange = Range(match.range(at: 4), in: line) {
                        jitter = Double(line[stddevRange]) ?? 0
                    }
                }
            }
        }

        return PingMetrics(
            host: host,
            latency: latency,
            jitter: jitter,
            packetLoss: packetLoss,
            isReachable: isReachable
        )
    }
}
