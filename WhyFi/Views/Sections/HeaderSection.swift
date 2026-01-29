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
    @State private var menuBarMetric1: MenuBarMetric
    @State private var menuBarMetric2: MenuBarMetric
    @State private var menuBarMetric3: MenuBarMetric

    init() {
        _launchAtLogin = State(initialValue: SettingsManager.shared.launchAtLogin)
        _colorfulIcon = State(initialValue: SettingsManager.shared.colorfulIcon)
        let metrics = SettingsManager.shared.menuBarMetrics
        _menuBarMetric1 = State(initialValue: metrics.count > 0 ? metrics[0] : .none)
        _menuBarMetric2 = State(initialValue: metrics.count > 1 ? metrics[1] : .none)
        _menuBarMetric3 = State(initialValue: metrics.count > 2 ? metrics[2] : .none)
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

            Divider()

            Text("Menu Bar Stats")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                MenuBarMetricBox(selection: $menuBarMetric1)
                    .onChange(of: menuBarMetric1) { _, newValue in
                        SettingsManager.shared.setMenuBarMetric(at: 0, to: newValue)
                    }
                MenuBarMetricBox(selection: $menuBarMetric2)
                    .onChange(of: menuBarMetric2) { _, newValue in
                        SettingsManager.shared.setMenuBarMetric(at: 1, to: newValue)
                    }
                MenuBarMetricBox(selection: $menuBarMetric3)
                    .onChange(of: menuBarMetric3) { _, newValue in
                        SettingsManager.shared.setMenuBarMetric(at: 2, to: newValue)
                    }
            }

            Divider()

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
        .frame(width: 260)
    }
}

struct MenuBarMetricBox: View {
    @Binding var selection: MenuBarMetric
    @State private var showingPicker = false

    var body: some View {
        Button {
            showingPicker.toggle()
        } label: {
            boxContent
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingPicker) {
            pickerContent
        }
    }

    private var boxContent: some View {
        VStack(spacing: 2) {
            if selection == .none {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            } else {
                Text(selection.icon)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                Text(selection.rawValue)
                    .font(.system(size: 8))
                    .lineLimit(1)
            }
        }
        .frame(width: 60, height: 44)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selection == .none ? Color.clear : Color.accentColor.opacity(0.5), lineWidth: 1)
        )
    }

    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(MenuBarMetric.allCases) { metric in
                MetricPickerRow(metric: metric, isSelected: metric == selection) {
                    selection = metric
                    showingPicker = false
                }
            }
        }
        .padding(8)
        .frame(width: 240)
    }
}

struct MetricPickerRow: View {
    let metric: MenuBarMetric
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                if metric != .none {
                    Text(metric.icon)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .frame(width: 32, alignment: .leading)
                }
                Text(metric.rawValue)
                    .font(.callout)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HeaderSection()
        .padding()
        .frame(width: 300)
}
