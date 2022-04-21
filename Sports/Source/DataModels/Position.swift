//
//  Position.swift
//  Sports
//
//  Created by Wesley St. John on 1/2/22.
//

import UIKit

enum Position: String, CaseIterable, Equatable, Codable {
    case keeper = "Keeper"
    case defender = "Defender"
    case midfielder = "Midfielder"
    case forward = "Forward"

    var shortName: String {
        switch self {
        case .keeper: return "GK"
        case .defender: return "D"
        case .midfielder: return "M"
        case .forward: return "F"
        }
    }

    var ordinalValue: Int {
        switch self {
        case .keeper: return 0
        case .defender: return 1
        case .midfielder: return 2
        case .forward: return 3
        }
    }

    var color: UIColor {
        switch self {
        case .keeper: return .brown
        case .defender: return GlassColor.green70.uiColor
        case .midfielder: return GlassColor.blue130.uiColor
        case .forward: return GlassColor.red80.uiColor
        }
    }
}
