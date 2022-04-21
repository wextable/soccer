//
//  GlassFont.swift
//  GlassUI
//
//  Created by Amisha Chordia on 25/06/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI
import UIKit

public extension UIFont {
    func italicized() -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: self.pointSize)
    }
}

///
/// This class defines typography font styles for the Walmart app based against https://zpl.io/VqqY43J
///
/// If your view needs something not contained here extend the class and use WalmartDynamicFont to
/// provide the additional font(s).
///
/// Leave any extension fonts added with internal access so as not to clash with other modules.
///
/// Descriptions of each font type include sizes on devices with less 600 pixels and devices with at least 600 pixels.
/// If same size on both, one size is included.
///
/// Example usage: GlassFont.captionRegular().swiftUIFont OR GlassFont.captionRegular().uiFont
///
open class GlassFont: NSObject {
    public let swiftUIFont: Font
    public let uiFont: UIFont

    init(uiFont: UIFont, swiftUIFont: Font) {
        self.swiftUIFont = swiftUIFont
        self.uiFont = uiFont
    }

    private class func isLargerSize(_ pixelHeight: CGFloat) -> Bool {
        pixelHeight >= 600
    }

    /// Bogle Bold (28 / 48).
    public class func displayText1(pixelHeight: CGFloat = 599) -> GlassFont {
        return WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 48 : 28).fontType
    }

    /// Bogle Bold (24 / 32)
    public class func displayText2(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 32 : 24).fontType
    }

    /// Bogle Bold (34 / 56).
    public class func displayText3(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 56 : 34).fontType
    }

    /// Bogle Bold (20 / 24)
    public class func pageTitle(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 24 : 20).fontType
    }

    /// Bogle Bold (18 / 20)
    public class func heading(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 20 : 18).fontType
    }

    /// Bogle Bold (16 / 18)
    public class func subheading1(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 18 : 16).fontType
    }

    /// Bogle Bold (14 / 16)
    public class func subheading2(pixelHeight: CGFloat = 599) -> GlassFont {
        WalmartDynamicFont.bold(isLargerSize(pixelHeight) ? 16 : 14).fontType
    }

    /// Bogle Regular (16)
    public class func body1() -> GlassFont {
        WalmartDynamicFont.regular(16).fontType
    }

    /// Bogle Regular (14)
    public class func body2() -> GlassFont {
        WalmartDynamicFont.regular(14).fontType
    }

    /// Bogle Regular (12)
    public class func captionRegular() -> GlassFont {
        WalmartDynamicFont.regular(12).fontType
    }

    /// Bogle Bold (12)
    public class func captionBold() -> GlassFont {
        WalmartDynamicFont.bold(12).fontType
    }

    /// Bogle Regular (12)
    public class func captionLight() -> GlassFont {
        WalmartDynamicFont.regular(12).fontType
    }
}

extension GlassFont {
    enum CustomFont: String, CaseIterable {
        case bogleRegular = "Bogle-Regular"
        case bogleBold = "Bogle-Bold"
        case bogleMedium = "Bogle-Medium"

        func font(ofSize size: CGFloat) -> UIFont {
            if let font = UIFont(name: rawValue, size: size) {
                return font
            } else {
                CustomFont.registerCustomFont()
                return UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
            }
        }

        func swiftUIFont(size: CGFloat) -> Font {
            Font.custom(rawValue, size: size)
        }

        static func registerCustomFont() {
            for name in CustomFont.allCases {

                guard let url = Bundle.glassUIBundle.url(forResource: name.rawValue, withExtension: "otf") else {
                    continue
                }

                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        }
    }
}

///
/// This enum defines typography font styles for the Walmart app based against https://zpl.io/VDZkR8e
///
/// In addition it supports a slightly modified version of dynamic type that uses the system setting
/// with the Walmart fonts and has custom scaling.
///
/// This allows the default size setting to match the design specifications but still allow the user
/// to scale the size up and down.
///
/// Also the support for dynamic text is put behind a setting switch so it could be supported but
/// not enabled until some point in the future when it makes sense to enable it.
///
/// It serves as a mashup wraper around iOS' built-in dynamic type and the Walmart design specs.
public enum WalmartDynamicFont {
    // MARK: Public API
    case regular(CGFloat)
    case bold(CGFloat)
    case medium(CGFloat)

    /// Set to `false` to disable dynamic type. Default value is `true`.
    public static var scaledFontsEnabled = true

    // MARK: Implementation
    ///     Returns a font in the standard GlassFont type for the theme in the specified size.
    public var fontType: GlassFont {
        let uiKitFont = uiFont
        let swiftUIFont = Font(uiKitFont)
        return GlassFont(uiFont: uiKitFont, swiftUIFont: swiftUIFont)
    }

    private var uiFont: UIFont {
        switch self {
        case .regular:
            return scaledFont(for: GlassFont.CustomFont.bogleRegular.font(ofSize: defaultSize))
        case .bold:
            return scaledFont(for: GlassFont.CustomFont.bogleBold.font(ofSize: defaultSize))
        case .medium:
            return scaledFont(for: GlassFont.CustomFont.bogleMedium.font(ofSize: defaultSize))
        }
    }

    var defaultSize: CGFloat {
        var size: CGFloat = 13.0
        switch self {
        case .regular(let defaultSize):
            size = defaultSize
        case .bold(let defaultSize):
            size = defaultSize
        case .medium(let defaultSize):
            size = defaultSize
        }
        return size
    }

    private func scaledFont(for font: UIFont) -> UIFont {
        guard WalmartDynamicFont.scaledFontsEnabled else {
            return font
        }

        return UIFontMetrics.default.scaledFont(for: font)
    }
}
