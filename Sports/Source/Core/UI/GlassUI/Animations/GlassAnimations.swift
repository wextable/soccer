//
//  GlassAnimations.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/30/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

///Standard location for animation durations
public enum GlassAnimation {
    case start
    case end

    public var alpha: CGFloat {
        switch self {
        case .start:
            return 0.0
        case .end:
            return 1.0
        }
    }

    ///0.15s
    public static let animationTimeShort = 0.15

    ///0.3s
    public static let animationTimeMedium = 0.3

    ///0.5s
    public static let animationTimeLong = 0.5
}
