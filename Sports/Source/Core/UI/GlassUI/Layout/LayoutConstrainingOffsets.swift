//
//  LayoutConstrainingOffsets.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import CoreGraphics
import Foundation

/// Offsets for use with the `LayoutConstraining`/`LayoutAnchorable` code.
///
/// The primary distinction between this type and `CGSize` or `CGPoint` is that the values are layout-based, rather than
/// screen-based. Specifically, the `horizontal` value represents an offset **away from the leading edge**, not strictly
/// in the positive-x direction.
public struct LayoutConstrainingOffsets: Hashable {
    public var vertical: CGFloat
    public var horizontal: CGFloat

    public var leading: CGFloat { horizontal }
    public var top: CGFloat { vertical }

    public static func uniform(_ offset: CGFloat) -> LayoutConstrainingOffsets {
        .init(offset)
    }

    public init(_ offset: CGFloat) {
        self.init(vertical: offset, horizontal: .init(offset))
    }

    public init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self.vertical = vertical
        self.horizontal = .init(horizontal)
    }
}

extension LayoutConstrainingOffsets: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Double) {
        self.init(CGFloat(value))
    }

    public init(integerLiteral value: Int) {
        self.init(CGFloat(value))
    }
}
