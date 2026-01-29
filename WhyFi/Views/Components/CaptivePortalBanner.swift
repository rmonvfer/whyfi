//
//  CaptivePortalBanner.swift
//  WhyFi
//
//  Created by Ramon on 1/28/26.
//

import AppKit
import SwiftUI

struct CaptivePortalBanner: View {
    let loginURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Text("Captive Portal Detected")
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }

            Text("This network requires login. Open a browser to authenticate.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                openLoginPage()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.forward.square")
                    Text("Open Login Page")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.orange.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func openLoginPage() {
        let url = loginURL ?? URL(string: "http://captive.apple.com")!
        NSWorkspace.shared.open(url)
    }
}

#Preview {
    VStack(spacing: 20) {
        CaptivePortalBanner(loginURL: URL(string: "http://wifi.example.com/login"))
        CaptivePortalBanner(loginURL: nil)
    }
    .padding()
    .frame(width: 360)
    .background(.black)
}
