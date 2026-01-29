//
//  Constants.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation

enum Constants: Sendable {
    static let pollingInterval: TimeInterval = 1.0
    static let historyCapacity = 60
    static let pingCount = 3
    static let pingTimeout: TimeInterval = 2.0

    static let internetHost = "1.1.1.1"
    static let dnsTestHost = "apple.com"

    static let cloudflareDownloadURL = "https://speed.cloudflare.com/__down?bytes=10000000"
    static let cloudflareUploadURL = "https://speed.cloudflare.com/__up"

    static let panelWidth: CGFloat = 360
}
