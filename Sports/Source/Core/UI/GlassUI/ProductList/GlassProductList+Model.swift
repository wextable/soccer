//
//  GlassProductList+Model.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension GlassProductList {
    /// Model used to populate the `GlassProductTile` view.
    struct Model {
        public var image: ImageModel?

        /// Whether the bottom divider is visible.
        public var isDividerHidden: Bool
        public var listStyle: ListStyle
        public var isOutOfStock: Bool = false
        public var isCloseButtonHidden: Bool = false

        public init(preserveInfoSpace: Bool = false,
                    image: ImageModel? = nil,
                    isDividerHidden: Bool = false,
                    listStyle: ListStyle = .details(name: nil, details: nil, price: nil, centerContent: nil),
                    isOutOfStock: Bool = false,
                    isCloseButtonHidden: Bool = false
        ) {
            self.image = image
            self.isDividerHidden = isDividerHidden
            self.listStyle = listStyle
            self.isOutOfStock = isOutOfStock
            self.image?.imageOpacity = isOutOfStock ? 0.35 : 1.0
            self.isCloseButtonHidden = isCloseButtonHidden
        }
    }

    /// A view model for display names, details, prices, etc.
    struct InfoModel {
        public var topInfoModel: TopInfoModel
        public var centerInfoModel: [CenterInfoModel]?
        public var discountInfoModel: [DiscountInfoModel]?
        public var carePlanModel: [CarePlanModel]?
        public var bottomSpacing: CGFloat
        public var bottomInfoModel: BottomInfoModel

        public init(topInfoModel: TopInfoModel,
                    centerInfoModels: [CenterInfoModel]? = nil,
                    discountInfoModels: [DiscountInfoModel]? = nil,
                    carePlanModel: [CarePlanModel]? = nil,
                    bottomInfoModel: BottomInfoModel,
                    bottomSpacing: CGFloat = .zero) {
            self.topInfoModel = topInfoModel
            self.centerInfoModel = centerInfoModels
            self.discountInfoModel = discountInfoModels
            self.carePlanModel = carePlanModel
            self.bottomInfoModel = bottomInfoModel
            self.bottomSpacing = bottomSpacing
        }
    }

    /// Model used to populate the pricing section of the `GlassProductTile` view.
    struct PriceModel {

        /// A stylized price string that includes the current price and optionally the strikeThrough and PPU price.
        public let primaryPrice: NSAttributedString

        /// A stylized price string of the pre-discounted price, if different from the primary price
        public let preDiscountedPrice: NSAttributedString?

        /// An optional message indicating the price is based on a weight measurement.
        public let weightMessage: String?

        /// An optional accessibility label for the primary price. Localizable.
        ///
        /// For example setting it to "was" and the price to "$1.99"
        /// will read "was - one dollar and ninety nine cents"
        public let primaryPriceAccessibilityLabel: String?

        /// An optional accessibility label for the pre-discount price. Localizable.
        ///
        /// For example setting it to "was" and the price to "$1.99"
        /// will read "was - one dollar and ninety nine cents"
        public var preDiscountedPriceAccessibilityLabel: String?

        /// Creates a `PriceModel` with the specified `primaryPrice`, `preDiscountedPrice`,
        /// and `weightText`.
        public init(
            primaryPrice: NSAttributedString,
            preDiscountedPrice: NSAttributedString? = nil,
            weightText: String?,
            primaryPriceAccessibilityLabel: String? = nil
        ) {
            self.primaryPrice = primaryPrice
            self.preDiscountedPrice = preDiscountedPrice
            self.weightMessage = weightText
            self.primaryPriceAccessibilityLabel = primaryPriceAccessibilityLabel
        }

        /// Creates and returned a stylized `PriceModel` given the various price components.
        ///
        /// - Parameters:
        ///   - price: The formatted current price string. e.g. `$100.00` or `From $100.00`
        ///   - pricePerUnit: An optional formatted price per unit string. e.g. `$0.99/lb`.
        ///   - isSoldByWeight: Whether the price is based of a weight measurement. This determines whether the "Final
        ///                     cost by weight" message is shown.
        public init(price: String = String(),
                    pricePerUnit: String? = nil,
                    isSoldByWeight: Bool = false,
                    priceAccessibilityLabel: String? = nil
        ) {
            let secondaryPriceAttributes: [NSAttributedString.Key: Any] = [
                .font: GlassFont.captionRegular().uiFont,
                .foregroundColor: GlassColor.gray100.uiColor
            ]

            primaryPrice = [
                NSAttributedString(
                    string: price.nonBreaking(),
                    attributes: [.font: GlassFont.subheading1().uiFont]
                ),
                pricePerUnit.map { NSAttributedString(string: $0.nonBreaking(), attributes: secondaryPriceAttributes) }
                ]
                .compactMap { $0 }
                .map { CollectionOfOne($0) }
                .joined(separator: CollectionOfOne(NSAttributedString(string: " ")))
                .reduce(NSMutableAttributedString(), { $0.append($1) ; return $0 })

            preDiscountedPrice = nil
            weightMessage = nil
            primaryPriceAccessibilityLabel = priceAccessibilityLabel
        }
    }

    struct ImageModel {

        public enum Size {
            case regular, regularSmall, small

            var dimension: CGFloat {
                switch self {
                case .regular: return 104
                case .regularSmall: return 72
                case .small: return 64
                }
            }
        }

        public enum Alignment {
            case leading, center

            var containerAlignment: UIStackView.Alignment {
                switch self {
                case .center: return .center
                case .leading: return .leading
                }
            }
        }

        public var imageConfigurator: ImageConfigurator?
        public var alignment: Alignment
        public var size: Size
        public var imageOpacity: CGFloat

        public init(imageConfigurator: ImageConfigurator? = nil,
                    alignment: Alignment = .center,
                    size: Size = .small,
                    imageOpacity: CGFloat = 1.0
        ) {
            self.imageConfigurator = imageConfigurator
            self.alignment = alignment
            self.size = size
            self.imageOpacity = imageOpacity
        }
    }
}

private extension StringProtocol {

    /// Replaces `" "`, `-`, and `/` with non-breaking equivalents.
    func nonBreaking() -> String {
        self
            .replacingOccurrences(of: " ", with: "\u{a0}")
            .replacingOccurrences(of: "-", with: "\u{2011}")
            .replacingOccurrences(of: "/", with: "/\u{2060}")
    }
}
