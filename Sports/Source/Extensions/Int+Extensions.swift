//
//  Int+Extensions.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import Foundation

extension Int {
    var teamOffenseStarRating: String {
        switch self {
        case Int.min..<64: return "⭐️"
        case 64..<70: return "⭐️⭐️"
        case 70..<75: return "⭐️⭐️⭐️"
        case 75..<82: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }

    var teamDefenseStarRating: String {
        switch self {
        case Int.min..<64: return "⭐️"
        case 64..<70: return "⭐️⭐️"
        case 70..<75: return "⭐️⭐️⭐️"
        case 75..<82: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }

    var teamOverallStarRating: String {
        switch self {
        case Int.min..<72: return "⭐️"
        case 72..<75: return "⭐️⭐️"
        case 75..<79: return "⭐️⭐️⭐️"
        case 79..<82: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }

    var playerOffenseStarRating: String {
        switch self {
        case Int.min..<70: return "⭐️"
        case 70..<75: return "⭐️⭐️"
        case 75..<80: return "⭐️⭐️⭐️"
        case 80..<85: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }

    var playerDefenseStarRating: String {
        switch self {
        case Int.min..<70: return "⭐️"
        case 70..<75: return "⭐️⭐️"
        case 75..<80: return "⭐️⭐️⭐️"
        case 80..<85: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }

    var playerOverallStarRating: String {
        switch self {
        case Int.min..<70: return "⭐️"
        case 70..<75: return "⭐️⭐️"
        case 75..<80: return "⭐️⭐️⭐️"
        case 80..<85: return "⭐️⭐️⭐️⭐️"
        default: return "⭐️⭐️⭐️⭐️⭐️"
        }
    }
}
