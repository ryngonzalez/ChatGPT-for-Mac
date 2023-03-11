//
//  ChatGPT_MenuApp.swift
//  ChatGPT-Menu
//
//  Created by Kathryn Gonzalez on 3/6/23.
//

import SwiftUI
import WebKit
import KeyboardShortcuts
import Combine

@main
struct ChatGPT_MenuApp: App {
    @Environment(\.openWindow) var openWindow
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsScreen()
                .environmentObject(appDelegate.appState)
                .keyboardShortcut(",", modifiers: .command)
                .background(VisualEffect().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .onChange(of: appDelegate.appState.showWindow) { value in
            appDelegate.togglePopover(nil)
        }
    }
}

