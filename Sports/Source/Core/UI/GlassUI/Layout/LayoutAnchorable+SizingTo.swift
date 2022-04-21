//
//  LayoutAnchorable+SizingTo.swift
//  GlassUI
//
//  Created by John Liedtke on 5/11/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension LayoutAnchorable {

    /// Creates constraints that fix the size of the view.
    ///
    /// The constraints have priority `UILayoutPriority.required` by default. Use the priority
    /// parameter to change it to a different priority.
    ///
    /// - Parameter size: The size to fix this view to.
    /// - Parameter priority: UILayoutPriority for all constraints that will be set. Default value is
    /// `UILayoutPriority.required`.
    ///
    /// - Returns: A `LayoutConstraining` instance that can be passed to `NSLayoutConstraint.activate()`
    func constraints(sizingTo size: CGSize,
                     priority: UILayoutPriority = .required) -> LayoutConstraining {
        [
            heightAnchor.constraint(equalToConstant: size.height),
            widthAnchor.constraint(equalToConstant: size.width)
            ].map { $0.with(priority: priority) }
    }
}
