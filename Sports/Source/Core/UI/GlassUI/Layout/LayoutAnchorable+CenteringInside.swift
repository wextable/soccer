//
//  LayoutConstraining+CenteringInside.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension LayoutAnchorable {

    /// Creates constraints that center this view within another view.
    ///
    /// The edges are also constrained to not exceed the other view.
    ///
    /// The constraints have priority `UILayoutPriority.required` by default. Use the priority
    /// parameter to change it to a different priority.
    ///
    /// # Offsets
    ///
    /// ## Horizontal
    /// An offset for the center of this view, relative to the center of the other view. A positive value shifts this
    /// view **away from its leading edge**.
    ///
    /// ## Vertical
    /// An offset for the center of this view, relative to the center of the other view. A positive value shifts this
    /// view **away from its top edge**.
    ///
    /// ## Horizontal & Vertical
    /// Offsets for the center of this view, relative to the center of the other view. Positive values shift this
    /// view **away from its top/leading edge**.
    ///
    /// - Parameter other: The view in which to center this view.
    /// - Parameter axes: The axes to center along. The default values are `LayoutConstrainingAxes.all`.
    /// - Parameter insets: Edge insets. This view is centered and sized relative to the insets. Default values are `0`.
    /// - Parameter offsets: Offsets for centering the view. See above for a detailed explanation.
    /// - Parameter priority: UILayoutPriority for all constraints that will be set. Default value is
    /// `UILayoutPriority.required`.
    ///
    /// - Returns: A `LayoutConstraining` instance that can be passed to `NSLayoutConstraint.activate()`
    func constraints(centeringInside other: LayoutAnchorable,
                     axes: LayoutConstrainingAxes = .all,
                     insets: LayoutConstrainingInsets = 0,
                     offsets: LayoutConstrainingOffsets = 0,
                     priority: UILayoutPriority = .required,
                     layoutDirection: UITraitEnvironmentLayoutDirection = UITraitCollection.current.layoutDirection)
        -> LayoutConstraining {

        var axesConstraints: [NSLayoutConstraint?] = []

        if axes.contains(.horizontal) {
            let insetLeadingOffset = offsets.horizontal + ((insets.leading - insets.trailing) / 2)
            let insetOffset = layoutDirection.convertToScreen(leading: insetLeadingOffset)

            let centeringConstraints = [
                centerXAnchor.constraint(equalTo: other.centerXAnchor, constant: insetOffset)
            ].map { $0.with(priority: priority) }

            guard let sizingConstraints =
                    // swiftlint:disable:next line_length
                constraints(pinningInside: other, edges: .horizontal, insets: insets, priority: priority) as? [NSLayoutConstraint?] else {
                    fatalError("constraints must be NSLayoutConstraint optionals")
            }

            axesConstraints += (centeringConstraints + sizingConstraints)
        }

        if axes.contains(.vertical) {
            let insetOffset = offsets.vertical + ((insets.top - insets.bottom) / 2)

            let centeringConstraints = [
                centerYAnchor.constraint(equalTo: other.centerYAnchor, constant: insetOffset)
            ].map { $0.with(priority: priority) }

            guard let sizingConstraints =
                    // swiftlint:disable:next line_length
                constraints(pinningInside: other, edges: .vertical, insets: insets, priority: priority) as? [NSLayoutConstraint?] else {
                    fatalError("constraints must be NSLayoutConstraint optionals")
            }

            axesConstraints += (centeringConstraints + sizingConstraints)
        }

        return axesConstraints
    }
}

private extension UITraitEnvironmentLayoutDirection {
    /// Converts from a layout-based value to a screen-based value.
    func convertToScreen(leading: CGFloat) -> CGFloat {
        switch self {
        case .rightToLeft:
            return -leading

        case .leftToRight, .unspecified: fallthrough
        @unknown default:
            return leading
        }
    }
}
