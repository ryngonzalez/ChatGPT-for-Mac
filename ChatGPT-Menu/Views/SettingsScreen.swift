//
//  SettingsScreen.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ScrollView {
            Form {
                VStack(alignment: .center, spacing: 32) {
                    VStack(alignment: .center) {
                        Image("SettingsIcon", bundle: .main)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 128, maxHeight: 128)
                            .background(
                                Color(red: 0.996, green: 0.176, blue: 0.494)
                                    .offset(x: 24, y: 24)
                                    .blur(radius: 60)
                                    .opacity(0.5)
                            )
                            .background(
                                Color(red: 0.808, green: 0.416, blue: 1)
                                    .offset(x: -12, y: -20)
                                    .blur(radius: 40)
                                    .opacity(0.5)
                            )
                            
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
        .background(Color.clear)
        .background(VisualEffect().ignoresSafeArea())
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
