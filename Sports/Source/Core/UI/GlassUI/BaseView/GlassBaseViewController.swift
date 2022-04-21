//
//  GlassBaseViewController.swift
//  GlassUI
//
//  Created by David Yundt on 7/7/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

open class GlassBaseViewController: BaseViewController {
    @available(*, unavailable, message: "You must use the NavigationAPI for all routing.")
    final public override var tabBarController: UITabBarController? {
        assertionFailure("You must use the NavigationAPI for all routing.")
        return nil
    }

    @available(*, unavailable, message: "You must use the NavigationAPI for all routing.")
    final override public func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil)
    {
        assertionFailure("You must use the NavigationAPI for all routing.")
    }

    @available(*, unavailable, message: "You must use the NavigationAPI for all routing.")
    final override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        assertionFailure("You must use the NavigationAPI for all routing.")
    }

    @_spi(NavigationAPIOnly)
    public func spi_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
}
