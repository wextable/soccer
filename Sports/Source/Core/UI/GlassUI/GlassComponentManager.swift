//
//  GlassComponentManager.swift
//  GlassUI
//
//  Created by Josh Mann on 4/13/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import SwiftUI
import UIKit

/// Central hub for system-wide theme selection. Performs two functions:
/// 1. Track and allow setting the currently selected theme
/// 2. Maintain and notify a list of subscribers of theme changes
public class GlassComponentManager: NSObject {
    public static let shared = GlassComponentManager()
}

public extension UIImage {
    /// Load an image from the GlassUI bundle according to the currently selected theme
    static func coreImage(named name: String, bundle: Bundle? = nil) -> UIImage? {
        let assetBundle: Bundle

        if let bundle = bundle {
            assetBundle = bundle
        } else {
            assetBundle = Bundle.glassUIBundle
        }

        return UIImage(named: "Glass/\(name)", in: assetBundle, compatibleWith: nil)
    }
}

public extension Image {
    /// Load an SwiftUI image from the GlassUI bundle according to the currently selected theme
    static func coreImage(named name: String, bundle: Bundle? = nil) -> Image {
        let assetBundle: Bundle

        if let bundle = bundle {
            assetBundle = bundle
        } else {
            assetBundle = Bundle.glassUIBundle
        }

        return Image("Glass/\(name)", bundle: assetBundle)
    }
}
