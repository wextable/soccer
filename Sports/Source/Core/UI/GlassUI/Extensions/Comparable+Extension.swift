//
//  Comparable+Extension.swift
//  GlassUI
//
//  Created by John Liedtke on 9/16/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import Foundation

extension Comparable {

    func clamped(to interval: ClosedRange<Self>) -> Self {
        return max(interval.lowerBound, min(self, interval.upperBound))
    }
}
