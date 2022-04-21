//
//  UIView+isViewObscured.swift
//  GlassUI
//
//  Created by John Liedtke on 9/2/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

public extension UIView {

    /// Thresholds for determining whther a view is considered obscured.
    enum VisibilityThreshold: Equatable {

        /// The view is 90% visible.
        case partial

        /// The view is 50% visible.
        case half

        /// A custom threshold between 0...1
        case custom(CGFloat)

        public var value: CGFloat {
            switch self {
            case .partial: return 0.90
            case .half: return 0.50
            case .custom(let value): return value
            }
        }
    }

    /// Returns a Boolean value indicating if `self` is obscured by checking if a view appears in front of it.
    ///
    /// This will also return true when the view is hidden, not in a window, and when view is partially or completely
    /// outside of a window's bounds.
    ///
    /// A view  is not consider obscured if less than 10% of its view is "covered" by a **single** other view.
    ///
    /// The default threshold for determining whether a view is obscured using the `isViewObscured(threshold:)` method.
    /// This value is `partial`.
    ///
    /// - Important: The method is not exhaustive and does not consider edge cases such as transforms.
    /// Additionally, this method should not be executed frequently for performance reasons as it requires traversing
    /// the view hierarchy.
    func isViewObscured(visibilityThreshold: VisibilityThreshold = .partial) -> Bool {
        guard bounds.size.height > 0, bounds.size.width > 0 else {
            return true
        }

        // it's obscuring itself!
        guard !isHidden else {
            return true
        }

        // no color!
        guard alpha != 0 else {
            return true
        }

        // check if view is in the hierarchy
        guard let window = window else {
            return true
        }

        let scrollView = enclosingScrollView

        // if in a scroll view, check if the `self` has been scrolled into view
        if let scrollView = scrollView,
           !isVisible(within: scrollView, threshold: visibilityThreshold)
        {
            return true
        }

        // if we're not in a scroll view, let's ensure we're in the window
        // todo: should we perform an `isVisible` check here too?
        if scrollView == nil ,
           !window.bounds.contains(window.convert(bounds, from: self))
        {
            // must be in the window's bounds
            return true
        }

        let obscuredThreshold = 1.0 - visibilityThreshold.value

        // recursively check the hierarchy to see if a view is front of `self`
        func _isViewObscuring(_ superview: UIView, previous: UIView) -> Bool {
            let index = superview.subviews.firstIndex(of: previous)!.advanced(by: 1)

            let potentialViewsInFront = index == superview.subviews.endIndex ? [] : Array(superview.subviews[index...])

            let convertedRectToCheck = self.convert(self.bounds, to: superview)
            let isViewObscured = potentialViewsInFront.contains { view -> Bool in

                // some views like prefetched table cells may be hidden and result in a false-positive
                guard !view.isHidden && view.alpha != 0 else {
                    return false
                }

                let intersection = view.frame.intersection(convertedRectToCheck)

                // null when there is no intersection
                guard !intersection.isNull else {
                    return false
                }

                let obscuredPercentage = intersection.area / convertedRectToCheck.area
                return obscuredPercentage > obscuredThreshold
            }

            if isViewObscured {
                return true
            } else if let next = superview.superview {
                return _isViewObscuring(next, previous: superview)
            } else {
                return false
            }
        }

        // initial superview check
        guard let superview = self.superview else {
            // not added to a view, so skip!
            return true
        }

        return _isViewObscuring(superview, previous: self)
    }
}

private extension UIView {

    /// Checks whether a view is visible within the provided `view`'s bounds.
    ///
    /// - Parameters:
    ///   - view: An ancestor of `self`.
    ///   - threshold: The visibility threshold.
    /// - Returns: Whether `self` is visible.
    func isVisible(within view: UIView, threshold: VisibilityThreshold) -> Bool {
        let intersection = view.bounds.intersection(self.convert(self.bounds, to: view))

        guard !intersection.isNull else {
            return false
        }

        let area = self.bounds.area

        guard area > 0 else {
            return false
        }

        let visiblePercentage = intersection.area / area
        return visiblePercentage > threshold.value
    }
}

private extension CGRect {

    var area: CGFloat {
        size.height * size.width
    }
}
