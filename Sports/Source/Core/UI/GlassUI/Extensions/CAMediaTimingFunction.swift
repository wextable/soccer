//
//  CAMediaTimingFunction.swift
//  GlassUI
//
//  Created by Jordan Perry on 5/18/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

internal extension CAMediaTimingFunction {
    static let easeInEaseOutCubic: CAMediaTimingFunction = .init(controlPoints: 0.645, 0.045, 0.355, 1)
}
