//
//  GlassStarRatingView+Model.swift
//  GlassUI
//
//  Created by John Liedtke on 5/6/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassStarRatingView {

    /// A view model for configuring a `GlassStarRatingView` instance.
    public struct Model {
        static let numberOfStars: Int = 5

        /// Allows hiding of the label and button
        public var shouldHideText: Bool = false

        /// The rating corresponding to the active stars.
        public let rating: Double

        /// The review count text. The count will be automatically formatted based on the `Style`, e.g. `1,337` or
        /// `1,337 reviews`
        public let numberOfReviews: Int

        /// Additional text for review count text. e.g. `1337 product reviews`
        /// Needs a space after the word e.g. `product ` or `seller `, so that the final text has proper spaces.
        public let additionalText: String

        func reviewText(for style: Style) -> String {
            switch style {
            case .abbreviated, .abbreviatedWithAverage:
                return "star-rating.abbreviated.reviewText".localize(numberOfReviews)
            case .expanded, .expandedWithAverage:
                return "star-rating.expanded.reviewText".localize(numberOfReviews, additionalText)
            }
        }

        func makeStarIcons() -> [UIImage] {
            let roundedRating = round(rating * 2.0) / 2.0
            return (0..<Self.numberOfStars).map {
                switch roundedRating - Double($0) {
                case 1...: return .starFill
                case 0.5...: return .starHalf
                default: return .star
                }
            }
        }

        public var accessibilityLabel: String {
            // swiftlint:disable line_length
            "rating \(String(format: "%.1f", rating)) out of five stars based on \(numberOfReviews) \(numberOfReviews == 1 ? "review" : "reviews")"
        }

        /// Creates and returns a `Model` with the provided parameters.
        public init(
            rating: Double = 0,
            numberOfReviews: Int = 0,
            shouldHideText: Bool = false,
            additionalText: String = ""
        ) {
            self.shouldHideText = shouldHideText
            self.rating = rating
            self.numberOfReviews = numberOfReviews
            self.additionalText = additionalText
        }
    }
}

extension UIImage {

    // Create stars once to save on computation.

    static let starFill = GlassIcon.starFill.image(.size12)
    static let starHalf = GlassIcon.starHalf.image(.size12)
    static let star = GlassIcon.star.image(.size12)
}
