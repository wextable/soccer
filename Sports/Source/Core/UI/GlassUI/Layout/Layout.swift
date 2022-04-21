//
//  Layout.swift
//  GlassUI
//
//  Created by Jordan Perry on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for declaring something as `Layoutable`, which means it is able to have a `Layouter` accessed and set.
public protocol Layoutable {
    var layout: Layouter? { get set }
}

/// Protocol for a `Layouter` object. One that can be initialized with a group of `LayoutConstraining` objects.
public protocol Layouter: AnyObject {
    /// Initializes with an array of `LayoutConstraining` objects.
    init(_ layoutConstraining: [LayoutConstraining])

    /// Activates the `LayoutConstraining` objects within.
    func activate()

    /// Deactivates the `LayoutConstraining` objects within.
    func deactivate()
}

public extension Layouter {
    init(_ layoutConstraining: LayoutConstraining...) {
        self.init(layoutConstraining)
    }
}

/// `Layout` is a concrete implementation of `Layouter`.
///
/// # Features
/// - Automatic activation on init
/// - Automatic deactivation on deinit
///
/// # Usage
/// ```
/// // Create an object capable of receiving a `Layouter` object
/// let layoutable: Layoutable = ...
///
/// layoutable.layout = Layout(
///     view1.constraints(pinningEdgesTo: view2)
/// )
/// ```
public class Layout: Layouter {
    private let constraining: [LayoutConstraining]

    public init(_ layoutConstraining: [LayoutConstraining], activate: Bool) {
        constraining = layoutConstraining

        guard activate else { return }

        self.activate()
    }

    public convenience init(activate: Bool, _ layoutConstraining: LayoutConstraining...) {
        self.init(layoutConstraining, activate: activate)
    }

    public required convenience init(_ layoutConstraining: [LayoutConstraining]) {
        self.init(layoutConstraining, activate: true)
    }

    deinit {
        deactivate()
    }

    public func activate() {
        NSLayoutConstraint.activate(constraining)
    }

    public func deactivate() {
        NSLayoutConstraint.deactivate(constraining)
    }
}

private enum UIViewAssociatedObject {
    static var layout: UInt8 = 0
}

/// Extend UIView to be `Layoutable`
extension UIView: Layoutable {
    public var layout: Layouter? {
        get {
            objc_getAssociatedObject(self, &UIViewAssociatedObject.layout) as? Layouter
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIViewAssociatedObject.layout,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
