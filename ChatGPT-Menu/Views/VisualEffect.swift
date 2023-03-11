//
//  VisualEffect.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}


struct VisualEffect_Previews: PreviewProvider {
    static var previews: some View {
        VisualEffect()
    }
}
