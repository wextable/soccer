//
//  GlassLabel.swift
//  GlassUI
//
//  Created by Josh Mann on 4/13/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// Glass Label Styles correlate to https://zpl.io/VqqY43J
///
/// style: font, size (small screen / large screen if applicable), color
/// * displayText1: Bogle-Bold, 28/48, #2e2f32
/// * displayText2: Bogle-Bold, 24/32, #2e2f32
/// * pageTitle: Bogle-Bold, 20/24, #2e2f32
/// * heading: Bogle-Bold, 18/20, #2e2f32
/// * subheading1: Bogle-Bold, 16/18, #2e2f32
/// * subheading2: Bogle-Bold, 14/16, #2e2f32
/// * body1: Bogle-Regular, 16, #46474a
/// * body2: Bogle-Regular, 14, #46474a
/// * captionRegular: Bogle-Regular, 12, #46474a
/// * captionBold: Bogle-Bold, 12, #46474a
///
public enum GlassLabelStyle {
    case displayText1 // previously title
    case displayText2 // previously displayText
    case displayText3
    case pageTitle
    case heading // previously header
    case subheading1 // previously subheader
    case subheading2
    case body1 // previously body1
    case body2 // previously body2, itemNameText
    case captionRegular // previously productSubTitle, caption
    case captionBold
    case captionLight // used for starRatingLabel

    // note that the following styles were removed in v20. would require setting your own color (all fonts are mapped):
    // productTitle, headline1, title1, title2

    public var font: GlassFont {
        switch self {
        case .displayText1:
            return GlassFont.displayText1()

        case .displayText2:
            return GlassFont.displayText2()

        case .displayText3:
            return GlassFont.displayText3()

        case .pageTitle:
            return GlassFont.pageTitle()

        case .heading:
            return GlassFont.heading()

        case .subheading1:
            return GlassFont.subheading1()

        case .subheading2:
            return GlassFont.subheading2()

        case .body1:
            return GlassFont.body1()

        case .body2:
            return GlassFont.body2()
        case .captionRegular:
            return GlassFont.captionRegular()

        case .captionBold:
            return GlassFont.captionBold()

        case .captionLight:
            return GlassFont.captionRegular()
        }
    }

    public var textColor: GlassColor {
        switch self {
        case .displayText1,
             .displayText2,
             .displayText3,
             .pageTitle,
             .heading,
             .subheading1,
             .subheading2:
            return .gray160

        case .body1,
             .body2,
             .captionRegular,
             .captionBold:
            return .gray140

        case .captionLight:
            return .gray100
        }
    }

    func configureLabel(_ label: UILabel) {
        label.font = font.uiFont
        label.textColor = textColor.uiColor
    }
}

/// Labels should use standard fonts and colors.
/// # Discussion
/// [Zeplin Reference](https://zpl.io/a70MqDj)
public class GlassLabel: UILabel, GlassPII {
    override public var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        if let edgeInset = edgeInsets {
            contentSize.height += edgeInset.top + edgeInset.bottom
            contentSize.width += edgeInset.left + edgeInset.right
        }
        return contentSize
    }

    public override var text: String? {
        didSet {
            self.isAccessibilityElement = true
            self.accessibilityLabel = text
        }
    }

    override public func drawText(in rect: CGRect) {
        if let edgeInsets = edgeInsets {
            super.drawText(in: rect.inset(by: edgeInsets))
        } else {
            super.drawText(in: rect)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit(observer: NotificationCenter.default)
    }

    override convenience init(frame: CGRect) {
        self.init(frame: frame, observer: NotificationCenter.default, style: .displayText1)
    }

    public convenience init(style: GlassLabelStyle) {
        self.init(frame: .zero, observer: NotificationCenter.default, style: style)
    }

    init(frame: CGRect,
         observer: GlassPIINotificationObserver,
         style: GlassLabelStyle)
    {
        super.init(frame: frame)
        postInit(observer: observer)
        setLabelStyle(style: style)
    }

    private func postInit(observer: GlassPIINotificationObserver) {
        self.adjustsFontForContentSizeCategory = true

        setupNotificationObservers(observer: observer)
    }

    private func setLabelStyle(style: GlassLabelStyle) {
        self.style = style
    }

    public var edgeInsets: UIEdgeInsets? {
        didSet {
            layoutIfNeeded()
        }
    }

    public var style: GlassLabelStyle = .displayText1 {
        didSet {
            style.configureLabel(self)
        }
    }

    public var containsPII: Bool = false

    // Container variable for the text that is currently obfuscated
    private var obfuscatedText: String?

    @objc
    public func obfuscatePII() {
        guard containsPII
        else {
            return
        }

        obfuscatedText = text
        text = nil
    }

    @objc
    public func deobfuscatePII() {
        guard containsPII,
              let obfuscatedText = self.obfuscatedText
        else {
            return
        }

        text = obfuscatedText
        self.obfuscatedText = nil
    }
}

#if DEBUG
extension GlassLabel {
    var testHooks: TestHooks {
        .init(target: self)
    }

    struct TestHooks {
        let target: GlassLabel

        var obfuscatedText: String? {
            target.obfuscatedText
        }
    }
}
#endif
