//
//  LayoutAnchorable+PinningEdgesTo.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public extension LayoutAnchorable {

    /// Creates constraints that pin a set of edges to another view.
    ///
    /// The constraints have priority `UILayoutPriority.required` by default. Use the priority
    /// parameter to change it to a different priority.
    ///
    /// - Parameter other: The view to pin this view to.
    /// - Parameter edges: A set of edges to pin this view to. The default value is `LayoutConstrainingEdges.all`.
    /// - Parameter insets: Edge insets. Edges that are constrained
    ///  (by passing a LayoutConstrainingEdges set) are constrained
    ///                     relative to the insets. Default values are `0`.
    /// - Parameter priority: UILayoutPriority for all constraints that will be set. Default value is
    /// `UILayoutPriority.required`.
    ///
    /// - Returns: A `LayoutConstraining` instance that can be passed to `NSLayoutConstraint.activate()`
    func constraints(
        pinningTo other: LayoutAnchorable,
        edges: LayoutConstrainingEdges = .all,
        insets: LayoutConstrainingInsets = 0,
        priority: UILayoutPriority = .required)
        -> LayoutConstraining {
        [
            edges.contains(.top) ? topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top) : nil,
            edges.contains(.leading) ? leadingAnchor.constraint(equalTo: other.leadingAnchor,
                                                                constant: insets.leading) : nil,
            edges.contains(.bottom) ? bottomAnchor.constraint(equalTo: other.bottomAnchor,
                                                              constant: -insets.bottom) : nil,
            edges.contains(.trailing) ? trailingAnchor.constraint(equalTo: other.trailingAnchor,
                                                                  constant: -insets.trailing) : nil
            ].map { $0?.with(priority: priority) }
    }
}
