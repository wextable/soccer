//
//  Presentation.swift
//  Sports
//
//  Created by Wesley St. John on 4/20/22.
//

import UIKit

enum Presentation {
    case present(UIViewController)
    case push(GlassNavigationController)

    var isPresent: Bool {
        switch self {
        case .present: return true
        default: return false
        }
    }

    var isPush: Bool {
        switch self {
        case .push: return true
        default: return false
        }
    }
}
