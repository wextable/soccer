//
//  UIWindow+Extension.swift
//  GlassUI
//
//  Created by John Liedtke on 11/22/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

public extension UIWindow {

    /// Hides the window by setting `isHidden` to true.
    func hide() {
        isHidden = true
    }

    /// Removes the window from the scene hierarchy by setting `isHidden` to `true` and `windowScene` to `nil`. The
    /// window is deallocated if there are no references to it.
    func dismiss() {
        isHidden = true
        windowScene = nil
    }
}
