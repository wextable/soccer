//
//  GlassBadge+Model.swift
//  GlassUI
//
//  Created by John Liedtke on 5/8/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassBadge {

    /// The view model of a `GlassBadge`.
    public struct Model {

        /// The various styles of a badge.
        public enum Style: Equatable {

            /// A badge with a 2.0 pt border.
            case outline

            /// A filled-in badge with an override of the `textColor`.
            case fill(textColor: GlassColor)
        }

        public var horizontalPadding: CGFloat

        /// The text to display on the badge.
        public var text: String?

        /// The preferred style of the badge.
        public var style: Style

        /// The color of the badge.
        public var badgeColor: GlassColor

        /// An optional icon to display adjacent to the leading edge of the badge.
        public var icon: GlassIcon?

        /// An optionall iconRenderingMode to determine if the badge should be tinted or not
        public let iconRenderingMode: UIImage.RenderingMode

        public var textColor: GlassColor {
            switch style {
            case .fill(let textColor): return textColor
            case .outline: return badgeColor
            }
        }

        public var borderColor: UIColor {
            switch style {
            case .fill: return .clear
            case .outline: return badgeColor.uiColor
            }
        }

        public var backgroundColor: GlassColor {
            switch style {
            case .fill: return badgeColor
            case .outline: return .gray00
            }
        }

        /// Creates and returns a `Model` with the provided parameters.
        public init(
            text: String?,
            badgeColor: GlassColor,
            icon: GlassIcon? = nil,
            style: Style,
            iconRenderingMode: UIImage.RenderingMode = .alwaysTemplate,
            horizontalPadding: CGFloat = GlassSpacing.xxSmall
        ) {
            self.text = text
            self.style = style
            self.badgeColor = badgeColor
            self.icon = icon
            self.iconRenderingMode = iconRenderingMode
            self.horizontalPadding = horizontalPadding
        }
    }
}

extension GlassBadge.Model {

    public enum BadgeType {
        case primary, secondary, tertiary, info

        var style: Style {
            switch self {
            case .primary: return .fill(textColor: .blue130)
            case .secondary: return .fill(textColor: .green100)
            case .tertiary: return .fill(textColor: .gray100)
            case .info: return .outline
            }
        }

        var badgeColor: GlassColor {
            switch self {
            case .primary: return .blue10
            case .secondary: return .green10
            case .tertiary: return .gray10
            case .info: return .gray100
            }
        }
    }

    public init(
        text: String? = nil,
        type: BadgeType = .primary,
        icon: GlassIcon? = nil,
        iconRenderingMode: UIImage.RenderingMode = .alwaysTemplate
    ) {
        self.init(text: text,
                  badgeColor: type.badgeColor,
                  icon: icon,
                  style: type.style,
                  iconRenderingMode: iconRenderingMode
        )
    }
}

public extension GlassBadge.Model {
    /// Walmart + Early access badge
    static func walmartPlusEarlyAccess(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.walmartPlusEarlyAccess".localize(),
                     badgeColor: GlassColor.blue90,
                     icon: .walmartPlusColor,
                     style: .outline,
                     iconRenderingMode: .alwaysOriginal,
                     horizontalPadding: GlassSpacing.xSmall)
    }
}
