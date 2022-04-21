//
//  AccessibilityCustomAction.swift
//  GlassUI
//
//  Created by Vishal Madheshia on 05/29/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// `UIAccessibilityCustomAction` with an action handler
class AccessibilityCustomAction: UIAccessibilityCustomAction {

    private var handler: ((UIAccessibilityCustomAction) -> Void)

    init(name: String, handler: @escaping ((UIAccessibilityCustomAction) -> Void)) {
        self.handler = handler
        super.init(name: name, target: nil, selector: #selector(didActivateCustomAction))
        self.target = self
    }

    @objc
    private func didActivateCustomAction() {
        handler(self)
    }
}
