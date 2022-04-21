//
//  Device+Extension.swift
//  GlassUI
//
//  Created by Amisha Chordia on 13/08/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

public extension UIDevice {
    func isIpad() -> Bool {
        return self.userInterfaceIdiom == .pad
    }

    func isLandscapeOrFlat() -> Bool {
        self.orientation.isLandscape || self.orientation.isFlat
    }
}

public extension UIScreen {
    // This gives the correct orientation. It includes landscape/prtrait while `Flat` orientation
    func isLandscape() -> Bool {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width > screenBounds.height
    }
}
