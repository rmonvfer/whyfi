//
//  HeaderSection.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import AppKit
import SwiftUI

struct HeaderSection: View {
    @State private var showingSettings = false

    var body: some View {
        HStack {
            Text("WhyFi")
                .font(.headline)

            Spacer()

            Button {
                showingSettings.toggle()
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingSettings) {
                SettingsPopover()
            }
        }
    }
}

struct SettingsPopover: View {
    @Environment(\.openURL) private var openURL
    @State private var launchAtLogin: Bool
    @State private var colorfulIcon: Bool

    init() {
        _launchAtLogin = State(initialValue: SettingsManager.shared.launchAtLogin)
        _colorfulIcon = State(initialValue: SettingsManager.shared.colorfulIcon)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    SettingsManager.shared.launchAtLogin = newValue
                }

            Toggle("Colorful Icon", isOn: $colorfulIcon)
                .onChange(of: colorfulIcon) { _, newValue in
                    SettingsManager.shared.colorfulIcon = newValue
                }

            Button("Reset Stats") {
                NotificationCenter.default.post(name: .resetStats, object: nil)
            }
            .buttonStyle(.plain)

            Divider()

            HStack {
                Text("WhyFi v1.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Website") {
                    if let url = URL(string: "https://whyfi.dev") {
                        openURL(url)
                    }
                }
                .buttonStyle(.link)
                .font(.caption)

                Button("GitHub") {
                    if let url = URL(string: "https://github.com/rmonvfer/WhyFi") {
                        openURL(url)
                    }
                }
                .buttonStyle(.link)
                .font(.caption)
            }

            Divider()

            Button("Quit WhyFi") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 240)
    }
}

#Preview {
    HeaderSection()
        .padding()
        .frame(width: 300)
}
