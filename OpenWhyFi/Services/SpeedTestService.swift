//
//  SpeedTestService.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

actor SpeedTestService {
    private let downloadURL = "https://speed.cloudflare.com/__down?bytes=10000000"
    private let uploadURL = "https://speed.cloudflare.com/__up"

    func runDownloadTest() async -> Double {
        guard let url = URL(string: downloadURL) else {
            return 0
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime

            guard elapsed > 0 else { return 0 }

            let bytesPerSecond = Double(data.count) / elapsed
            let mbps = (bytesPerSecond * 8) / 1_000_000
            return mbps
        } catch {
            return 0
        }
    }

    func runUploadTest() async -> Double {
        guard let url = URL(string: uploadURL) else {
            return 0
        }

        let uploadData = Data(count: 1_000_000)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            let (_, _) = try await URLSession.shared.upload(for: request, from: uploadData)
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime

            guard elapsed > 0 else { return 0 }

            let bytesPerSecond = Double(uploadData.count) / elapsed
            let mbps = (bytesPerSecond * 8) / 1_000_000
            return mbps
        } catch {
            return 0
        }
    }

    func runFullTest() async -> SpeedTestMetrics {
        async let download = runDownloadTest()
        async let upload = runUploadTest()

        let (downloadSpeed, uploadSpeed) = await (download, upload)

        return SpeedTestMetrics(
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            isRunning: false,
            lastTestTime: Date()
        )
    }
}
