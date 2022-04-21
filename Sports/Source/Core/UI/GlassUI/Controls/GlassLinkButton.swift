//
//  GlassLinkButton.swift
//  GlassUI
//
//  Created by Simon Bilsky-Rollins on 5/13/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A text link button that is designed to be used as a lightweight alternative to primary or secondary buttons.
///
/// Default values: 16pt font, black text, clear background, 24px height, no edge insets.
///
/// [Zeplin reference](https://zpl.io/25B9P9j)
open class GlassLinkButton: UIButton {

    private static let underlinePadding: CGFloat = -3

    public enum Size {
        /// 16pt font, 24px height.
        case large
        /// 14pt font, 20px height.
        case small

        var font: UIFont {
            switch self {
            case .large: return GlassFont.body1().uiFont
            case .small: return GlassFont.body2().uiFont
            }
        }

        var height: CGFloat {
            switch self {
            case .large: return 24
            case .small: return 20
            }
        }
    }

    public struct Model: Equatable {
        /// The size of the link button's text and total height. Defaults to `.large`.
        public var size: Size
        /// The color of the button's text and underline in the normal state. Defaults to `GlassColor.gray200`.
        public var normalColor: UIColor
        /// The color of the button's text and underline in the highlighted state. Defaults to `GlassColor.gray110`.
        public var highlightedColor: UIColor
        /// The color of the button's text and underline in the disabled state. Defaults to `GlassColor.gray40`.
        public var disabledColor: UIColor
        /// The font of the button's text. If `nil`, the button will choose a default font based on its size.
        public var font: UIFont?
        /// The font of the button adjusts to fit the text within its width
        public var adjustFontSizeToFitWidth: Bool

        public init(
            size: Size = .small,
            normalColor: UIColor = GlassColor.gray200.uiColor,
            highlightedColor: UIColor = GlassColor.gray110.uiColor,
            disabledColor: UIColor = GlassColor.gray40.uiColor,
            font: UIFont? = nil,
            adjustFontSizeToFitWidth: Bool = true
        ) {
            self.size = size
            self.normalColor = normalColor
            self.highlightedColor = highlightedColor
            self.disabledColor = disabledColor
            self.font = font
            self.adjustFontSizeToFitWidth = adjustFontSizeToFitWidth
        }
    }

    public var model: GlassLinkButton.Model {
        didSet { applyModel() }
    }

    /// A block which will be invoked after taps (`touchUpInside`)
    ///
    /// As always with blocks be careful not to create retention cycles.
    public var onTap: GlassButtonTapHandler?

    /// Default init override
    override public init(frame: CGRect) {
        self.model = GlassLinkButton.Model()
        super.init(frame: frame)
        postInit()
    }

    public init(model: Model = Model()) {
        self.model = model

        super.init(frame: .zero)
        postInit()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func postInit() {
        if model.adjustFontSizeToFitWidth {
            titleLabel?.adjustsFontSizeToFitWidth = model.adjustFontSizeToFitWidth
            titleLabel?.adjustsFontForContentSizeCategory = model.adjustFontSizeToFitWidth
        } else {
            titleLabel?.lineBreakMode = .byTruncatingTail
        }
        titleLabel?.baselineAdjustment = .alignCenters
        titleLabel?.minimumScaleFactor = 0.5
        contentMode = .redraw

        applyModel()
        registerTapHandler()
    }

    open override var isHighlighted: Bool {
        didSet { setNeedsDisplay() }
    }

    open override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height = model.size.height
        return contentSize
    }

    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        accessibilityLabel = title
        setNeedsDisplay()
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let titleFrame = titleLabel?.frame else { return }

        let strokeColor = isHighlighted ? model.highlightedColor : isEnabled ? model.normalColor : model.disabledColor

        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setStrokeColor(strokeColor.cgColor)

        contextRef?.move(to: CGPoint(
            x: titleFrame.origin.x,
            y: titleFrame.origin.y + titleFrame.size.height + Self.underlinePadding
        ))

        contextRef?.addLine(to: CGPoint(
            x: titleFrame.origin.x + titleFrame.size.width,
            y: titleFrame.origin.y + titleFrame.size.height + Self.underlinePadding
        ))

        contextRef?.closePath()
        contextRef?.drawPath(using: .stroke)
    }

    private func applyModel() {
        setTitleColor(model.normalColor, for: .normal)
        setTitleColor(model.highlightedColor, for: .highlighted)
        setTitleColor(model.disabledColor, for: .disabled)

        titleLabel?.font = model.font ?? model.size.font
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.higAppropriateTapRect.contains(point)
    }
}
