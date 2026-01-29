//
//  MenuBarIcon.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct MenuBarIcon: View {
    let isConnected: Bool
    let signalQuality: SignalQuality

    var body: some View {
        Image(systemName: iconName)
    }

    private var iconName: String {
        if !isConnected {
            return "wifi.exclamationmark"
        }

        switch signalQuality {
        case .excellent, .good:
            return "wifi"
        case .fair:
            return "wifi"
        case .weak, .poor:
            return "wifi.exclamationmark"
        case .disconnected:
            return "wifi.slash"
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        MenuBarIcon(isConnected: true, signalQuality: .excellent)
        MenuBarIcon(isConnected: true, signalQuality: .weak)
        MenuBarIcon(isConnected: false, signalQuality: .disconnected)
    }
    .padding()
}
