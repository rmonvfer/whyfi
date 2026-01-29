//
//  OpenWhyFiApp.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import SwiftUI

@main
struct OpenWhyFiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
