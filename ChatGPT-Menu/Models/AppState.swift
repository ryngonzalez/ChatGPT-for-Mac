//
//  AppState.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import SwiftUI
import KeyboardShortcuts

final class AppState: ObservableObject {
    @Published var showWindow: Bool = false
    @Published var showPreferences: Bool = false
    @Published var pageZoomLevel: PageZoomLevel = .default
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .showWindow) { [self] in
            showWindow.toggle()
        }
    }
}
