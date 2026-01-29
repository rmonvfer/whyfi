//
//  WiFiService.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import CoreWLAN
import Foundation

actor WiFiService {
    private let wifiClient = CWWiFiClient.shared()
    private let emptyMetrics = WiFiMetrics(
        ssid: nil,
        bssid: nil,
        rssi: -100,
        noise: -100,
        channel: 0,
        linkRate: 0,
        frequencyBand: .unknown
    )

    func getCurrentMetrics() -> WiFiMetrics {
        guard let interface = wifiClient.interface() else {
            return emptyMetrics
        }

        let ssid = interface.ssid()
        let bssid = interface.bssid()
        let rssi = interface.rssiValue()
        let noise = interface.noiseMeasurement()
        let channel = interface.wlanChannel()?.channelNumber ?? 0
        let linkRate = interface.transmitRate()

        return WiFiMetrics(
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            noise: noise,
            channel: channel,
            linkRate: linkRate,
            frequencyBand: FrequencyBand(channel: channel)
        )
    }

    var isConnected: Bool {
        guard let interface = wifiClient.interface() else {
            return false
        }
        return interface.ssid() != nil
    }
}
