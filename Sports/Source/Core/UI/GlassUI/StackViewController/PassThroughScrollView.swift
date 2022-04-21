//
//  PassThroughScrollView.swift
//  GlassUI
//
//  Created by David Yundt on 9/16/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import UIKit

/// `UIScrollView` subclass that allows taps to pass through to the content
/// behind it whenever its descendents don't catch the tap.
public class PassThroughScrollView: UIScrollView {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        subviews.contains {
            let convertedPoint = $0.convert(point, from: self)
            return $0.point(inside: convertedPoint, with: event)
        }
    }
}
