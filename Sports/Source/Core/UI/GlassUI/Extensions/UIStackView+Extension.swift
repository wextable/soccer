//
//  UIStackView+Extension.swift
//  GlassUI
//
//  Created by Thomas Hartnett on 4/28/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension UIStackView {

    /// Removes all arranged subviews from the `arrangedSubviews` array. It does **not** remove the arranged
    /// subviews from the view hierarchy.
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach(removeArrangedSubview(_:))
    }

    /// Convenience initializer that allows you to set the `axis`, `alignment`, and/or `distribution` when creating the
    /// stack view.
    /// - Author: Alex Johnson
    convenience init(axis: NSLayoutConstraint.Axis,
                     alignment: UIStackView.Alignment = .fill,
                     distribution: UIStackView.Distribution = .fill) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
    }

    /// Appends the contents of `views` to the end of the `arrangedSubviews` array.
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview(_:))
    }

    /// Appends the contents of `views` to the end of the `arrangedSubviews` array.
    func addArrangedSubviews(_ views: UIView...) {
        addArrangedSubviews(views)
    }

    /// Adds an arranged subview and applies custom spacing after the specified view.
    ///
    /// - Parameters:
    ///   - arrangedSubview: e view to be added to the array of views arranged by the stack.
    ///   - spacing: The amount of spacing.
    func addArrangedSubview(_ arrangedSubview: UIView, customSpacing spacing: CGFloat) {
        addArrangedSubview(arrangedSubview)
        setCustomSpacing(spacing, after: arrangedSubview)
    }
}

internal extension UIStackView {

    /// Embeds `view` in an axis-aware container with the provided `alignment` and appends the container to the stack
    /// view's `addArrangedSubviews`.
    ///
    /// - Precondition: `UIStackView.alignment` must be `fill`.
    func addArrangedContainerizedSubview(_ view: UIView, alignment: ContainerView.Alignment) {
        assert(self.alignment == .fill)

        let containerView = ContainerView(view, axis: axis == .vertical ? .vertical : .horizontal, alignment: alignment)
        addArrangedSubview(containerView)
    }
}
