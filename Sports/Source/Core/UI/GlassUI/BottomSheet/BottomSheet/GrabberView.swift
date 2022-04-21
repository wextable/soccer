//
//  GrabberView.swift
//  GlassUI
//
//  Created by Joshua Mann on 8/20/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

class GrabberView: UIView, Accessible {
    public var accessibilityIncrementCallback: (() -> Void)?
    public var accessibilityDecrementCallback: (() -> Void)?

    override func accessibilityDecrement() {
        accessibilityDecrementCallback?()
    }

    override func accessibilityIncrement() {
        accessibilityIncrementCallback?()
    }
}
