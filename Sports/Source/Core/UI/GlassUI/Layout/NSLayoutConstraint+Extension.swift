//
//  NSLayoutConstraint+Extension.swift
//  GlassUI
//
//  Created by John Liedtke on 1/22/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    /// A convenience method for changing the priority from `required` to `requiredCompliant`.
    public func compliant() -> NSLayoutConstraint {
        assert(priority == .required)
        priority = .requiredCompliant
        return self
    }

    /// Sets the layout priority of `self` to the provided `priority` and returns `self`
    ///
    /// - Author: Jordan Perry
    /// - Parameter priority: layout priority to set `self` to
    /// - Returns: `self`
    public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
