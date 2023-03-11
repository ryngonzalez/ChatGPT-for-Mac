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

extension KeyboardShortcuts.Name {
    static let showWindow = Self("showWindow")
}

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

struct MenuView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        WebView(url: URL(string: "https://chat.openai.com")!, pageZoomLevel: $appState.pageZoomLevel)
            .frame(width: 480, height: 640)
    }
}

struct SettingsScreen: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        Form {
            VStack(alignment: .center, spacing: 32) {
                VStack(alignment: .center) {
                    Image("SettingsIcon", bundle: .main)
                    Text("ChatGPT for Mac")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                    Text("Created by [@ryngonzalez](https://twitter.com/ryngonzalez)")
                        .font(.system(.body, design: .rounded))
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Settings")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                    KeyboardShortcuts.Recorder("Global Shortcut:", name: .showWindow)
                    Picker(selection: $appState.pageZoomLevel) {
                        ForEach(PageZoomLevel.allCases, id: \.rawValue) { value in
                            Text(value.localizedName).tag(value)
                        }
                    } label: {
                        Text("Zoom Level:").frame(width: 100, alignment: .leading)
                    }
                }
            }
        }
        .padding([.horizontal, .bottom], 64)
        .padding(.top, 24)
        .frame(minWidth: 480, minHeight: 480)
    }
}
 
enum PageZoomLevel: CGFloat, CaseIterable, Equatable {
    case xLarge = 1.2
    case large = 1.1
    case `default` = 1.0
    case small = 0.90
    case xSmall = 0.80
    
    var localizedName: String {
        switch self {
        case .xLarge:
            return "Extra Large"
        case .large:
            return "Large"
        case .default:
            return "Medium (Default)"
        case .small:
            return "Small"
        case .xSmall:
            return "Extra Small"
        }
    }
}

struct WebView: NSViewRepresentable {
    var url: URL
    @Binding var pageZoomLevel: PageZoomLevel
 
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
//        var requiresDrawBackgroundFallback = false
        configuration.setValue(false, forKey: "drawsBackground")

//        if #available(OSX 10.14, *) {
//            configuration.setValue(false, forKey: "sward".reversed() + "background".capitalized) //drawsBackground KVC hack; works but private
//        } else {
//            requiresDrawBackgroundFallback = true
//        }
        let webView = WKWebView(frame: .zero, configuration: configuration)
//        if requiresDrawBackgroundFallback {
//            webView.setValue(false, forKey: "sward".reversed() + "background".capitalized) //drawsBackground KVC hack; works but private
//        }
        DispatchQueue.main.async {
            let request = URLRequest(url: url)
            webView.load(request)
            injectToPage(webView: webView)
        }
        return webView
    }
 
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.pageZoom = pageZoomLevel.rawValue
    }
    
    private func readFileBy(name: String, type: String) -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            return "Failed to find path"
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            return "Unkown Error"
        }
    }
    
    func injectToPage(webView: WKWebView) {
        let cssFile = readFileBy(name: "styles", type: "css")
        let jsFile = readFileBy(name: "scripts", type: "js")
        
        let cssStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = window.atob('\(encodeStringTo64(fromString: cssFile)!)');
            parent.appendChild(style)})()
        """
        
        let jsStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.innerHTML = window.atob('\(encodeStringTo64(fromString: jsFile)!)');
            parent.appendChild(script)})()
        """

        let cssScript = WKUserScript(source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let jsScript = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        webView.configuration.userContentController.addUserScript(cssScript)
        webView.configuration.userContentController.addUserScript(jsScript)
    }
    
    // 4
    // MARK: - Encode string to base 64
    private func encodeStringTo64(fromString: String) -> String? {
        let plainData = fromString.data(using: .utf8)
        return plainData?.base64EncodedString(options: [])
    }
}

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

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

