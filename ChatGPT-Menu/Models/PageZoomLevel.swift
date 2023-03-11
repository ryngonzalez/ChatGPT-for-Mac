//
//  PageZoomLevel.swift
//  ChatGPT for Mac
//
//  Created by Kathryn Gonzalez on 3/10/23.
//

import Foundation

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
