//
//  LayoutConstrainingEdges.swift
//  GlassUI
//
//  Created by John Liedtke on 4/29/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation

/// Constrainable view edges to be used with `LayoutConstraining`/`LayoutAnchorable` code.
public struct LayoutConstrainingEdges: OptionSet {
    private static let mask = 0b1111

    public let rawValue: Int

    public init(rawValue: Int) {
        assert(rawValue == 0 || Self.mask & rawValue != 0, "Invalid `LayoutConstrainingEdges.rawValue`: \(rawValue)")
        self.rawValue = rawValue
    }

    // The top edge of a view.
    public static let top = LayoutConstrainingEdges(rawValue: 0b0001)

    /// The leading edge of a view.
    public static let leading = LayoutConstrainingEdges(rawValue: 0b0010)

    /// The bottom edge of a view.
    public static let bottom = LayoutConstrainingEdges(rawValue: 0b0100)

    /// The trailing edge of a view.
    public static let trailing = LayoutConstrainingEdges(rawValue: 0b1000)

    /// All edges of a view.
    public static let all: LayoutConstrainingEdges = LayoutConstrainingEdges(rawValue: mask)

    /// The horizontal edges of a view, i.e. `[.leading, .trailing]`.
    public static let horizontal: LayoutConstrainingEdges = [.leading, .trailing]

    /// The vertical edges of a view, i.e. `[.top, bottom]`.
    public static let vertical: LayoutConstrainingEdges = [.top, .bottom]
}
