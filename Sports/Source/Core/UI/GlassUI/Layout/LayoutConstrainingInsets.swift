//
//  LayoutConstrainingInsets.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import CoreGraphics
import Foundation

/// Insets for use with the `LayoutConstraining`/`LayoutAnchorable` code.
///
/// The primary distinction between this type and `UIEdgeInsets` is that the values are layout-based, rather than
/// screen-based. Specifically, the `horizontal` insets are for leading/trailing edges, not left/right edges.
///
/// The primary distinction between this type and `SwiftUI.EdgeInsets` or `NSDirectionalEdgeInsets` is that the vertical
/// and horizontal insets are separated. This enables APIs that are only concerned with horizontal or vertical edges
/// (not both).
public struct LayoutConstrainingInsets: Hashable {
    public var vertical: Vertical
    public var horizontal: Horizontal

    /// Horizontal insets for use with the `LayoutConstraining`/`LayoutAnchorable` code.
    public struct Horizontal: Hashable {
        public var leading: CGFloat
        public var trailing: CGFloat

        public init(leading: CGFloat = 0, trailing: CGFloat = 0) {
            self.leading = leading
            self.trailing = trailing
        }

        public static func uniform(_ leadingAndTrailing: CGFloat) -> Horizontal {
            .init(leadingAndTrailing)
        }

        public init(_ leadingAndTrailing: CGFloat) {
            self.init(leading: leadingAndTrailing, trailing: leadingAndTrailing)
        }
    }

    /// Vertical insets for use with the `LayoutConstraining`/`LayoutAnchorable` code.
    public struct Vertical: Hashable {
        public var top: CGFloat
        public var bottom: CGFloat

        public init(top: CGFloat = 0, bottom: CGFloat = 0) {
            self.top = top
            self.bottom = bottom
        }

        public static func uniform(_ topAndBottom: CGFloat) -> Vertical {
            .init(topAndBottom)
        }

        public init(_ topAndBottom: CGFloat) {
            self.init(top: topAndBottom, bottom: topAndBottom)
        }
    }

    public var top: CGFloat { vertical.top }
    public var leading: CGFloat { horizontal.leading }
    public var bottom: CGFloat { vertical.bottom }
    public var trailing: CGFloat { horizontal.trailing }

    init(wrapping vertical: Vertical) {
        self.vertical = vertical
        self.horizontal = 0
    }

    init(wrapping horizontal: Horizontal) {
        self.vertical = 0
        self.horizontal = horizontal
    }

    public init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        self.vertical = .init(top: top, bottom: bottom)
        self.horizontal = .init(leading: leading, trailing: trailing)
    }

    public static func uniform(_ inset: CGFloat) -> LayoutConstrainingInsets {
        .init(inset)
    }

    public init(_ inset: CGFloat) {
        self.init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }

    public init(top: CGFloat = 0, horizontal: CGFloat, bottom: CGFloat = 0) {
        self.init(top: top, leading: horizontal, bottom: bottom, trailing: horizontal)
    }

    public init(vertical: CGFloat, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.init(top: vertical, leading: leading, bottom: vertical, trailing: trailing)
    }

    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

extension LayoutConstrainingInsets: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Double) {
        self.init(CGFloat(value))
    }

    public init(integerLiteral value: Int) {
        self.init(CGFloat(value))
    }
}

extension LayoutConstrainingInsets.Vertical: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Double) {
        self.init(CGFloat(value))
    }

    public init(integerLiteral value: Int) {
        self.init(CGFloat(value))
    }
}

extension LayoutConstrainingInsets.Horizontal: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Double) {
        self.init(CGFloat(value))
    }

    public init(integerLiteral value: Int) {
        self.init(CGFloat(value))
    }
}
