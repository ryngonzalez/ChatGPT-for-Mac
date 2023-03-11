//
//  MenuView.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        WebView(url: URL(string: "https://chat.openai.com")!, pageZoomLevel: $appState.pageZoomLevel)
            .frame(width: 480, height: 640)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
