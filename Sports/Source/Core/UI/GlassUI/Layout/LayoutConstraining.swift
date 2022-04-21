//
//  LayoutConstraining.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/22/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    /// Activates a collection of `LayoutConstraining` instances.
    static func activate(_ constrainers: [LayoutConstraining]) {
        activate(constrainers.reduce(into: [], { $1.appendConstraints(to: &$0) }))
    }

    /// Activates a collection of `LayoutConstraining` instances.
    static func activate(_ constrainers: LayoutConstraining...) {
        activate(constrainers)
    }

    /// Deactivates a collection of `LayoutConstraining` instances.
    static func deactivate(_ constrainers: [LayoutConstraining]) {
        deactivate(constrainers.reduce(into: [], { $1.appendConstraints(to: &$0) }))
    }

    /// Deactivates a collection of `LayoutConstraining` instances.
    static func deactivate(_ constrainers: LayoutConstraining...) {
        deactivate(constrainers)
    }
}

/// Describes a type that can be used to constrain the layout of a UIKit layout.
///
/// Typically you will not need to implement this protocol yourself; you will use the provided conformances.
///
/// Example:
/// ```
/// NSLayoutConstraint.activate(
///   activityIndicatorView.constraints(centeringIn: layoutMarginsGuide),
///   //...
/// )
/// ```
public protocol LayoutConstraining {
    /// Appends constraints to array `NSLayoutConstraint`
    /// - Parameter array: an array of `NSLayoutConstraint`
    func appendConstraints(to array: inout [NSLayoutConstraint])
    /// Activates single `LayoutConstraining` instance
    func activate()

    func deactivate()
}

public extension LayoutConstraining {
    func activate() {
        NSLayoutConstraint.activate(self)
    }

    func deactivate() {
        NSLayoutConstraint.deactivate(self)
    }
}

extension NSLayoutConstraint: LayoutConstraining {
    public func appendConstraints(to array: inout [NSLayoutConstraint]) {
        array.append(self)
    }
}

extension Array: LayoutConstraining where Element: LayoutConstraining {
    public func appendConstraints(to array: inout [NSLayoutConstraint]) {
        forEach { $0.appendConstraints(to: &array) }
    }
}

extension Optional: LayoutConstraining where Wrapped: LayoutConstraining {
    public func appendConstraints(to array: inout [NSLayoutConstraint]) {
        self?.appendConstraints(to: &array)
    }
}
