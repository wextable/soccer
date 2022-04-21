//
//  LayoutConstrainingAxes.swift
//  GlassUI
//
//  Created by John Liedtke on 4/30/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation

/// Constrainable axes to be used with `LayoutConstraining`/`LayoutAnchorable` code.
public struct LayoutConstrainingAxes: OptionSet {
    private static let mask = 0b11

    public let rawValue: Int

    public init(rawValue: Int) {
        assert(rawValue == 0 || Self.mask & rawValue != 0, "Invalid `LayoutConstrainingAxes.rawValue`: \(rawValue)")
        self.rawValue = rawValue
    }

    /// The horizontal axis of a view.
    public static let horizontal = LayoutConstrainingAxes(rawValue: 0b01)

    /// The vertical axis of a view.
    public static let vertical = LayoutConstrainingAxes(rawValue: 0b10)

    /// All of the axes, i.e. `[.horizontal, vertical]`
    public static let all = LayoutConstrainingAxes(rawValue: mask)
}
