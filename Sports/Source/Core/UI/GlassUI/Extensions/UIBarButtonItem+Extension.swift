//
//  UIBarButtonItem+Extension.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/12/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    enum CoreItem: Int {
        case bottomSheetClose

        var image: UIImage? {
            switch self {
            case .bottomSheetClose:
                return GlassIcon.close.imageSize24()
            }
        }

        var style: UIBarButtonItem.Style {
            switch self {
            case .bottomSheetClose:
                return .done
            }
        }
    }
}

public extension UIBarButtonItem {
    convenience init(barButtonCoreItem coreItem: CoreItem, target: Any?, action: Selector?) {
        self.init(image: coreItem.image, style: coreItem.style, target: target, action: action)
    }
}
