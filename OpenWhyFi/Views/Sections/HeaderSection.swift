//
//  HeaderSection.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

struct HeaderSection: View {
    @State private var showingSettings = false

    var body: some View {
        HStack {
            Text("OpenWhyFi")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            Divider()

            Toggle("Launch at Login", isOn: .constant(false))
                .disabled(true)

            Divider()

            HStack {
                Text("OpenWhyFi v1.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("GitHub") {
                    if let url = URL(string: "https://github.com") {
                        openURL(url)
                    }
                }
                .buttonStyle(.link)
                .font(.caption)
            }
        }
        .padding()
        .frame(width: 220)
    }
}

#Preview {
    HeaderSection()
        .padding()
        .frame(width: 300)
}
