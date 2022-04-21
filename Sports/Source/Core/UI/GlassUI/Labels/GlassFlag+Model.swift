//
//  GlassFlag+Model.swift
//  GlassUI
//
//  Created by John Liedtke on 5/8/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassFlag {

    /// The view model of a `GlassFlag`.
    public struct Model {

        /// The various styles of a flag.
        //swiftlint:disable nesting
        public enum Style: Equatable {

            /// A flag with a 2.0 pt border.
            case outline

            /// A filled-in flag with an override of the `textColor`. The default `textColor` is `GlassColor.gray00`.
            case fill(textColor: GlassColor = .gray00)
        }
        //swiftlint:enableable nesting

        /// The text to display on the flag.
        public var text: String?

        /// The preferred style of the flag.
        public var style: Style

        /// The color of the flag.
        public var flagColor: GlassColor?

        var textColor: GlassColor? {
            switch style {
            case .fill(let textColor): return textColor
            case .outline: return flagColor
            }
        }

        var image: UIImage {
            let image: UIImage
            switch style {
            case .fill: image = UIImage.coreImage(named: "flag-background-filled")!
            case .outline: image = UIImage.coreImage(named: "flag-background")!
            }

            return image.resizableImage(
                withCapInsets: .init(top: 2.0, left: 2.0, bottom: 2.0, right: 26.0),
                resizingMode: .stretch
            )
        }

        /// Creates and returns a `Model` with the provided parameters.
        public init(text: String? = nil, flagColor: GlassColor? = nil, style: Style = .outline) {
            self.text = text
            self.style = style
            self.flagColor = flagColor
        }
    }
}

public extension GlassFlag.Model {

    /// Padding Space used by the Item Team with no text and gray00 flag background color.
    static var paddingSpaceFlag: Self {
        return .init(text: "", flagColor: .gray00, style: .fill(textColor: .blue120))
    }

    /// The standard "Customer Pick" flag.
    static func customerPick(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.customerPick".localize(),
                     flagColor: .blue120, style: .outline)
    }

    /// The standard "Clearance" flag.
    static func clearance(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.clearance".localize(),
                     flagColor: .blue120, style: .outline)
    }

    /// The standard "Best seller" flag.
    static func bestSeller(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.bestSeller".localize(),
                     flagColor: .blue120, style: .outline)
    }

    /// The standard "Reduced Price" flag.
    static func reducedPrice(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.reducedPrice".localize(),
                     flagColor: .blue120, style: .outline)
    }

    /// The standard "Rollback" flag.
    static func rollback(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.rollback".localize(),
                     flagColor: .red100, style: .outline)
    }

    /// The standard "todaysDeal" flag.
    static func todaysDeal(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.todaysDeal".localize(),
                     flagColor: .green130, style: .outline)
    }

    /// Flag to display explicit text.
    static func dynamic(text: String) -> Self {
        return .init(text: text, flagColor: .blue120, style: .outline)
    }

    /// The standard "Holiday" flag
    static func holiday(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.holidayDeal".localize(),
                     flagColor: .spark100,
                     style: .fill(textColor: .black))
    }

    /// The standard "W+ Early access" flag
    static func wPlusEarlyAccess(text: String? = nil) -> Self {
        return .init(text: text ?? "product-tile.flag.walmartPlusEarlyAccess".localize(),
                     flagColor: .blue100,
                     style: .outline)
    }

    /// The standard "Bought Number of Times" flag.
    static func previouslyPurchased(text: String? = nil) -> Self {
        .init(
            text: text ?? "product-tile.label.boughtBefore".localize(),
            flagColor: .gray00,
            style: .fill(textColor: .blue120)
        )
    }
}
