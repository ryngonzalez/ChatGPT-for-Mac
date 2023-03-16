//
//  AppDelegate.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import Foundation
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @ObservedObject var appState = AppState()
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var hostingController: NSHostingController<AnyView>?
    var cancellables: [AnyCancellable] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {        
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "message.and.waveform.fill", accessibilityDescription: "Button")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(handleAction(_:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        // Create the SwiftUI view and the HostingController
        let contentView = MenuView()
            .environmentObject(appState)
        hostingController = NSHostingController(rootView: AnyView(contentView))

        // Create the popover and set the HostingController as its content view controller
        popover = NSPopover()
        popover.contentSize.width = 480
        popover.contentSize.height = 640
        popover.contentViewController = hostingController
        popover.behavior = .applicationDefined
        
        cancellables.append(contentsOf: [
            appState.$showWindow
                .dropFirst()
                .print() // Prints all publishing events.
                .sink(receiveValue: { [weak self] showWindow in
                    guard let self = self else { return }
                    self.togglePopover(nil)
                })
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.togglePopover(self)
        }
    }

    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem.button {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func showSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    @objc func handleAction(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp ||
            event.type == .leftMouseUp && event.modifierFlags.contains(.control) {
            showSettingsWindow()
        } else {
            togglePopover(sender)
        }
    }
}
