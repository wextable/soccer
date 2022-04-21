//
//  GlassSpacing.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/6/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public class GlassSpacing: NSObject {
    ///Size of 4
    public static let xxSmall: CGFloat = 4
    ///Size of 8
    public static let xSmall: CGFloat = 8
    ///Size of 16
    public static let small: CGFloat = 16
    ///Size of 24
    public static let mediumSmall: CGFloat = 24
    ///Size of 32
    public static let medium: CGFloat = 32
    ///Size of 48
    public static let mediumLarge: CGFloat = 48
    ///Size of 64
    public static let large: CGFloat = 64
    ///Size of 80
    public static let xLarge: CGFloat = 80
    ///Size of 96
    public static let xxLarge: CGFloat = 96

    public static let allValues: [CGFloat] = CGFloat.GlassSpacing.allCases.map(\.rawValue)
}

public extension CGFloat {

    /// The standard spacing for views.
    enum GlassSpacing: CGFloat, CaseIterable {

        /// Size of 4
        case xxSmall = 4

        /// Size of 8
        case xSmall = 8

        /// Size of 16
        case small = 16

        /// Size of 24
        case mediumSmall = 24

        /// Size of 32
        case medium = 32

        /// Size of 48
        case mediumLarge = 48

        /// Size of 64
        case large = 64

        /// Size of 80
        case xLarge = 80

        /// Size of 96
        case xxLarge = 96
    }

    static func glassSpacing(_ spacing: GlassSpacing) -> Self {
        spacing.rawValue
    }
}
