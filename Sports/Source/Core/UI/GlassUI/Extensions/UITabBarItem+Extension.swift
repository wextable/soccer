//
//  UITabBarItem+Extension.swift
//  GlassUI
//
//  Created by Amisha Chordia on 09/08/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

public extension UITabBarItem {
    func setTabBarItemImageInsets(deviceType: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) {
        let topInset = deviceType == .pad ? 0 : GlassSpacing.xxSmall
        let bottomInset = deviceType == .pad ? 0 : -GlassSpacing.xxSmall
        imageInsets = UIEdgeInsets(top: topInset,
                                   left: 0,
                                   bottom: bottomInset,
                                   right: 0)
    }
}
