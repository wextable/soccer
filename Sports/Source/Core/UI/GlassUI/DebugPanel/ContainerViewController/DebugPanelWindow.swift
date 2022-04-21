//
//  DebugPanelWindow.swift
//  DebugPanel
//
//  Created by Bharath Rao on 15/01/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

#if DEBUG
import UIKit

/// Visibility provider
public protocol VisibilityProvider {
    /// Hides the component
    func hide()

    /// Shows the component
    func show()
}

public class DebugPanelWindow: UIWindow, VisibilityProvider {

    /// Shows UIWindow
    public func show() {
        isHidden = false
    }
}
#endif
