//
//  WebView.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var url: URL
    @Binding var pageZoomLevel: PageZoomLevel
 
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.setValue(false, forKey: "drawsBackground")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
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

    private func encodeStringTo64(fromString: String) -> String? {
        let plainData = fromString.data(using: .utf8)
        return plainData?.base64EncodedString(options: [])
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://google.com")!, pageZoomLevel: .constant(.default))
    }
}
