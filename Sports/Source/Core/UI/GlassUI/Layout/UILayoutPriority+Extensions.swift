//
//  UILayoutPriority+Extensions.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/22/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension UILayoutPriority {
    /// A priority to use in place of `required`, for example when there is a need to tolerate being temporarily
    /// zero-sized.
    public static let requiredCompliant = UILayoutPriority.required.decreased

    /// Gets the next (whole number) priority higher than this one.
    public var increased: UILayoutPriority {
        return UILayoutPriority(rawValue: min(rawValue + 1, UILayoutPriority.required.rawValue))
    }

    /// Gets the next (whole number) priority lower than this one.
    public var decreased: UILayoutPriority {
        return UILayoutPriority(rawValue: max(0, rawValue - 1))
    }
}
