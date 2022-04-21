//
//  GlassImageDimension.swift
//  GlassUI
//
//  Created by Chordia, Amisha (US - Mumbai) on 1/11/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import UIKit

/// Standard image dimensions as defined by keylines
public class GlassImageDimension: NSObject {

    open class var size12: CGSize {
        return CGSize(width: 12.0, height: 12.0)
    }

    open class var size16: CGSize {
        return CGSize(width: 16.0, height: 16.0)
    }

    open class var size24: CGSize {
        return CGSize(width: 24.0, height: 24.0)
    }

    open class var size32: CGSize {
        return CGSize(width: 32.0, height: 32.0)
    }

    open class var size40: CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }

    open class var size48: CGSize {
        return CGSize(width: 48.0, height: 48.0)
    }

    open class var xsmall: CGFloat {
        return 70.0
    }

    open class var small: CGFloat {
        return 90.0
    }

    open class var medium: CGFloat {
        return 148.0
    }

    public static let large: CGFloat = 204.0
    public static let heroImage: CGFloat = 144.0
}
