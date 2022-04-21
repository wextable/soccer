//
//  GlassSecondaryButton.swift
//  GlassUI
//
//  Created by John Liedtke on 7/7/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A button designed for less vital actions such as skipping or resetting.
///
/// [Zeplin reference](https://zpl.io/V4BojBM)
open class GlassSecondaryButton: UIButton {

    /// A type representing the standard sizes of a secondary button.
    public enum Size {

        /// 16pt font
        case large

        /// 14pt font
        case small

        /// The font associated with the size.
        public var font: UIFont {
            switch self {
            case .large: return GlassFont.subheading1().uiFont
            case .small: return GlassFont.subheading2().uiFont
            }
        }

        /// The content edge insets associated with the size.
        public var contentEdgeInsets: UIEdgeInsets {
            switch self {
            case .large:
                return .init(
                    top: GlassSpacing.xSmall,
                    left: GlassSpacing.mediumSmall,
                    bottom: GlassSpacing.xSmall,
                    right: GlassSpacing.mediumSmall
                )
            case .small:
                return .init(
                    top: GlassSpacing.xxSmall,
                    left: GlassSpacing.small,
                    bottom: GlassSpacing.xxSmall,
                    right: GlassSpacing.small
                )
            }
        }
    }

    /// The view model of the buton.
    public struct Model {

        /// The color of the button when it is in the normal state.
        public var normalColor: Color

        /// The color of the button when it is in the highlighted state.
        public var highlightedColor: Color

        /// The color of the button when it is in the disabled state.
        public var disabledColor: Color

        /// The font of the button's title.
        public var font: UIFont?

        /// The content edge insets of the button.
        public var contentEdgeInsets: UIEdgeInsets

        /// A type representing the customized colors of the button.
        public struct Color {

            /// The background color of the button.
            public var background: UIColor

            /// The border color of the button.
            public var border: UIColor

            /// The color of the title in the button.
            public var title: UIColor

            /// Creates and returns `Color` instance with the provides values.
            public init(background: UIColor, border: UIColor, title: UIColor) {
                 self.background = background
                 self.border = border
                 self.title = title
             }

            /// The default color for the normal state.
            public static var normal: Color {
                .init(background: GlassColor.gray00.uiColor,
                      border: GlassColor.gray200.uiColor,
                      title: GlassColor.gray200.uiColor)
            }

            /// The default color for the highlighted state.
            public static var highlighted: Color {
                .init(background: GlassColor.gray20.uiColor,
                      border: GlassColor.gray50.uiColor,
                      title: GlassColor.gray110.uiColor)
            }

            /// The default color for the disabled state.
            public static var disabled: Color {
                .init(background: GlassColor.gray00.uiColor,
                      border: GlassColor.gray50.uiColor,
                      title: GlassColor.gray50.uiColor)
            }
        }

        /// Creates and returns a button with the provided configuration values.
        public init(
            normalColor: Color = .normal,
            highlightedColor: Color = .highlighted,
            disabledColor: Color = .disabled,
            font: UIFont?,
            contentEdgeInsets: UIEdgeInsets
        ) {
            self.normalColor = normalColor
            self.highlightedColor = highlightedColor
            self.disabledColor = disabledColor
            self.font = font
            self.contentEdgeInsets = contentEdgeInsets
        }
    }

    /// The current view model of the button.
    open var model: Model {
        didSet { applyModel() }
    }

    open override var isHighlighted: Bool {
        didSet { applyBorderColor() }
    }

    open override var isEnabled: Bool {
        didSet {
            applyBorderColor()
            if isEnabled {
                accessibilityTraits = [.button]
            } else {
                accessibilityTraits = [.button, .notEnabled]
            }
        }
    }

    /// A block which will be invoked after taps (`touchUpInside`)
    ///
    /// As always with blocks be careful not to create retention cycles.
    public var onTap: GlassButtonTapHandler?

    /// Default init override
    override public init(frame: CGRect) {
        self.model = Model(font: Size.large.font, contentEdgeInsets: Size.large.contentEdgeInsets)
        super.init(frame: frame)
        postInit()
    }

    /// Creates and returns a button with the provided `model` applied.
    public init(model: Model) {
        self.model = model

        super.init(frame: .zero)
        postInit()
    }

    private func postInit() {
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.minimumScaleFactor = 0.5
        layer.borderWidth = 1.0
        layer.masksToBounds = true

        applyModel()
        registerTapHandler()
    }

    /// A convenience for creating a button with the styling of the `size`.
    public convenience init(size: Size) {
        self.init(model: .init(font: size.font, contentEdgeInsets: size.contentEdgeInsets))
    }

    /// A convenience initializer for compatibility with the legacy secondary button. This initializer has the same
    /// effect of calling `init(size:)`.
    public convenience init(buttonStyle: Size = .large) {
        self.init(size: buttonStyle)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyModel() {
        contentEdgeInsets = model.contentEdgeInsets

        setTitleColor(model.normalColor.title, for: .normal)
        setTitleColor(model.highlightedColor.title, for: .highlighted)
        setTitleColor(model.disabledColor.title, for: .disabled)

        setBackgroundColor(model.normalColor.background, for: .normal)
        setBackgroundColor(model.highlightedColor.background, for: .highlighted)
        setBackgroundColor(model.disabledColor.background, for: .disabled)

        titleLabel?.font = model.font

        applyBorderColor()
    }

    private func applyBorderColor() {
        switch state {
        case .highlighted:
            layer.borderColor = model.highlightedColor.border.cgColor
        case .disabled:
            layer.borderColor = model.disabledColor.border.cgColor
        default:
            layer.borderColor = model.normalColor.border.cgColor
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.size.height / 2.0
    }
}
