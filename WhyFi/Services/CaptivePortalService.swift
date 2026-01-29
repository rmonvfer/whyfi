//
//  CaptivePortalService.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

actor CaptivePortalService {
    private let detectURL = "http://captive.apple.com/hotspot-detect.html"
    private let expectedResponse = "<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>"

    func checkForCaptivePortal() async -> CaptivePortalStatus {
        guard let url = URL(string: detectURL) else {
            return .unknown
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .unknown
            }

            guard let body = String(data: data, encoding: .utf8) else {
                return .unknown
            }

            if httpResponse.statusCode == 200 && body.contains("Success") {
                return .noPortal
            }

            if let finalURL = httpResponse.url, finalURL.host != url.host {
                return .detected(loginURL: finalURL)
            }

            if httpResponse.statusCode == 302 || httpResponse.statusCode == 301 {
                if let location = httpResponse.value(forHTTPHeaderField: "Location"),
                   let redirectURL = URL(string: location) {
                    return .detected(loginURL: redirectURL)
                }
            }

            return .detected(loginURL: nil)
        } catch {
            return .unknown
        }
    }
}

enum CaptivePortalStatus: Equatable {
    case noPortal
    case detected(loginURL: URL?)
    case unknown

    var isDetected: Bool {
        if case .detected = self {
            return true
        }
        return false
    }
}
