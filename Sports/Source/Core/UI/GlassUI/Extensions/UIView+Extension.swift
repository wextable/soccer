//
//  UIView+Extension.swift
//  GlassUI
//
//  Created by John Liedtke on 4/30/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension UIView {

    /// A convenience method for adding a subview and setting `translatesAutoresizingMaskIntoConstraints` to `false` at
    /// the same time. Use this wherever you would normally use `addSubview()` (assuming you want to use constraint-
    /// based layout), and you won't have to worry about setting that flag again.
    ///
    /// - Author: Alex Johnson
    /// - Note: `UIStackView` takes care of this for arranged subviews, so you don't need an
    /// `addArrangedAutoLayoutSubview()` method.
    func addAutoLayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    /// A convenience method for adding subviews and setting `translatesAutoresizingMaskIntoConstraints` to `false` at
    /// the same time. Use this wherever you would normally use `addSubview()` (assuming you want to use constraint-
    /// based layout), and you won't have to worry about setting that flag again.
    ///
    ///
    /// - Note: `UIStackView` takes care of this for arranged subviews, so you don't need an
    /// `addArrangedAutoLayoutSubview()` method.
    func addAutoLayoutSubviews(_ subviews: [UIView]) {
        subviews.forEach({ addAutoLayoutSubview($0) })
    }

    /// A convenience method for adding subviews and setting `translatesAutoresizingMaskIntoConstraints` to `false` at
    /// the same time. Use this wherever you would normally use `addSubview()` (assuming you want to use constraint-
    /// based layout), and you won't have to worry about setting that flag again.
    ///
    ///
    /// - Note: `UIStackView` takes care of this for arranged subviews, so you don't need an
    /// `addArrangedAutoLayoutSubview()` method.
    func addAutoLayoutSubviews(_ subviews: UIView...) {
        subviews.forEach({ addAutoLayoutSubview($0) })
    }

    /// The perfect way to round corners for a UIView. After invoking this method, the corners of your view will
    /// perfectly match the corners of your iPhone X family device.
    func roundCorners(corners: UIRectCorner = .allCorners, radius: CGFloat = 38.5) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    }

    /// An opaque sequence of this view's superviews, starting with its immediate superview.
    var superviews: AnySequence<UIView> {
        AnySequence(sequence(first: self, next: { $0.superview }).dropFirst())
    }

    /// The nearest superview that is a `UIScrollView`.
    var enclosingScrollView: UIScrollView? {
        superviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }

    /// Helper property to use when animating constraints. Call `self.targetLayoutView.layoutIfNeeded()` at the end of
    /// the `animations` block of `UIView.animated()`, instead of the usual `self.layoutIfNeeded()`.
    ///
    /// When animating constraints that change the content height of a scroll view, we need to call `layoutIfNeeded()`
    /// on the scroll view. Otherwise, the scroll view's content size changes immediately, out of sync with the
    /// animation.
    var targetLayoutView: UIView {
        enclosingScrollView ?? self
    }

    /// Applies the drop shadow style for a view
    func applyDropShadowStyle(offset: CGSize, opacity: Float, radius: CGFloat, color: GlassColor) {
        layer.masksToBounds = false
        layer.shadowColor = color.uiColor.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
