//
//  UIControl+OnTapBlocks.swift
//  GlassUI
//
//  Created by Gil Shinar on 2020-12-24.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Callback block to handle taps in glass buttons
public typealias GlassButtonTapHandler = () -> Void

/// Internal protocol so we can place most of the logic here
@objc protocol ControlWithBlockHandler {
    /// A block which will be invoked after taps (`touchUpInside`)
    ///
    /// As always with blocks be careful not to create retention cycles.
    var onTap: GlassButtonTapHandler? { get set }

    func invokeTapBlock()
}

extension ControlWithBlockHandler where Self: UIControl {
    func registerTapHandler() {
        self.addTarget(self, action: #selector(invokeTapBlock), for: .touchUpInside)
    }
}

// This code duplication is required due to Swift limitation with @objc method being prototyped
// @objc can only be used with members of classes, @objc protocols, and concrete extensions of classes
extension GlassButton: ControlWithBlockHandler {
    @objc
    func invokeTapBlock() {
        self.onTap?()
    }
}

extension GlassLinkButton: ControlWithBlockHandler {
    @objc
    func invokeTapBlock() {
        self.onTap?()
    }
}

extension GlassCheckbox: ControlWithBlockHandler {
    @objc
    func invokeTapBlock() {
        self.onTap?()
    }
}

extension GlassSecondaryButton: ControlWithBlockHandler {
    @objc
    func invokeTapBlock() {
        self.onTap?()
    }
}
