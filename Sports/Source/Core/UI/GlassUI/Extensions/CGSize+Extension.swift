//
//  CGSize+Extension.swift
//  GlassUI
//
//  Created by John Liedtke on 5/11/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension CGSize {

    /// Creates a size with the same width and height dimension.
    init(_ uniformDimension: CGFloat) {
        self.init(width: uniformDimension, height: uniformDimension)
    }
}
