//
//  DNSService.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

actor DNSService {
    private let testHostname = "apple.com"

    func measureLookupTime() async -> DNSMetrics {
        let dnsServer = getDNSServer() ?? "Unknown"
        let startTime = CFAbsoluteTimeGetCurrent()

        let success = await performDNSLookup(hostname: testHostname)
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

        return DNSMetrics(
            server: dnsServer,
            lookupTime: success ? elapsed : 0,
            isWorking: success
        )
    }

    private func performDNSLookup(hostname: String) async -> Bool {
        await withCheckedContinuation { continuation in
            var hints = addrinfo()
            hints.ai_family = AF_UNSPEC
            hints.ai_socktype = SOCK_STREAM

            var result: UnsafeMutablePointer<addrinfo>?

            let status = getaddrinfo(hostname, nil, &hints, &result)
            if status == 0 {
                freeaddrinfo(result)
                continuation.resume(returning: true)
            } else {
                continuation.resume(returning: false)
            }
        }
    }

    private func getDNSServer() -> String? {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/sbin/scutil")
        process.arguments = ["--dns"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                return nil
            }

            return parseDNSServer(from: output)
        } catch {
            return nil
        }
    }

    private func parseDNSServer(from output: String) -> String? {
        let lines = output.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("nameserver[0]") {
                let components = trimmed.components(separatedBy: ":")
                if components.count >= 2 {
                    return components[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }

        return nil
    }
}
