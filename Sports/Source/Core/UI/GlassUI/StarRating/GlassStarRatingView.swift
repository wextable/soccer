//
//  GlassStarRatingView.swift
//  GlassUI
//
//  Created by Joshua Mann & John Liedtke on 4/29/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A view for displaying a customer rating in a five star format.
///
/// The view comes in two styles: `Style.abbreviated` and `Style.expanded`. The abbreviated style is typically used on
/// product tiles while the expanded style is used on the item page as a navigation button to the review page.
///
/// # Reference
/// [Zeplin](https://zpl.io/aB0roep)
public class GlassStarRatingView: BaseView {

    /// The various styles of the the star rating view.
    public enum Style {

        /// Displays the stars and the rating count. e.g. `⭑⭑⭑⭒⭒ 23`
        case abbreviated

        /// Displays the stars, the average in parenthesis and the review count button. e.g. `⭑⭑⭑⭒⭒ (3.0) 23`
        ///
        /// - See [JIRA Ticket OAMD-468](https://jira.walmart.com/browse/OAMD-468)
        case abbreviatedWithAverage

        /// Displays the stars and a rating count button. e.g. `⭑⭑⭑⭒⭒ 23 reviews`
        case expanded

        /// Displays the stars, the average in parenthesis and the review count button. e.g. `⭑⭑⭑⭒⭒ (3.0) 23 reviews`
        ///
        /// - See [JIRA Ticket OAMD-468](https://jira.walmart.com/browse/OAMD-468)
        case expandedWithAverage
    }

    /// The model powering the star rating view.
    /// - Note: Setting to `nil` does nothing.
    public var model: Model {
        didSet { applyModel() }
    }

    private let starStackView: UIStackView = UIStackView(axis: .horizontal, alignment: .center)
    private let mainStackView: UIStackView = UIStackView(axis: .horizontal, alignment: .center)

    private let ratingsLabel: GlassLabel?
    private let averageLabel: GlassLabel?
    internal let reviewButton: GlassLinkButton?
    private var starImageViews: [UIImageView] {
        // swiftlint:disable:next force_cast
        starStackView.arrangedSubviews as! [UIImageView]
    }

    /// The style of the rating view.
    public let style: Style

    /// The handler to call when a user taps on `self`.
    public var onTapHandler: (() -> Void)?

    /// Creates a rating view with the provided `style` and `model`.
    ///
    /// - Parameters:
    ///   - style: The preferred style of the rating view. This cannot be changed. The default value is `abbreviated`.
    ///   - model: The view model to configure the rating view. The default value is `nil`.
    public init(style: Style = .abbreviated, model: Model = Model()) {
        self.style = style
        self.model = model

        switch style {
        case .abbreviated:
            ratingsLabel = GlassLabel(style: .captionLight)
            averageLabel = nil
            reviewButton = nil

        case .abbreviatedWithAverage:
            ratingsLabel = GlassLabel(style: .captionLight)
            averageLabel = GlassLabel(style: .body2)
            reviewButton = nil

        case .expanded:
            ratingsLabel = nil
            averageLabel = nil
            reviewButton = GlassLinkButton()

        case .expandedWithAverage:
            ratingsLabel = nil
            averageLabel = GlassLabel(style: .body2)
            reviewButton = GlassLinkButton()
        }

        ratingsLabel?.isHidden = model.shouldHideText
        reviewButton?.isHidden = model.shouldHideText

        super.init(frame: .zero)

        applyModel()
    }

    public override func constructView() {
        super.constructView()

        reviewButton?.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        let starImageViews = (0..<Model.numberOfStars).map { _ in UIImageView() }
        starImageViews.forEach { $0.contentMode = .scaleAspectFit }
        starStackView.addArrangedSubviews(starImageViews)
        mainStackView.addArrangedSubview(starStackView)
        mainStackView.addArrangedSubviews([averageLabel, ratingsLabel, reviewButton].compactMap { $0 })
        addAutoLayoutSubview(mainStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        mainStackView.spacing = GlassSpacing.xxSmall
        NSLayoutConstraint.activate(
            mainStackView.constraints(
                pinningTo: self,
                edges: [.leading, .vertical],
                insets: .init(vertical: GlassSpacing.xxSmall)
            ),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        )
    }

    @objc private func handleTap() {
        onTapHandler?()
    }
}

// MARK: - Apply Model

extension GlassStarRatingView {

    private func applyModel() {
        let reviewText = model.reviewText(for: style)
        ratingsLabel?.text = reviewText
        reviewButton?.setTitle(reviewText, for: .normal)
        averageLabel?.text = String(format: "(%.1f)", model.rating)
        zip(model.makeStarIcons(), starImageViews).forEach { icon, imageView in
            imageView.image = icon
        }
    }
}

// MARK: - Testhooks

#if DEBUG
extension GlassStarRatingView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        var target: GlassStarRatingView

        var reviewButton: GlassLinkButton? { target.reviewButton }
        var averageLabel: GlassLabel? { target.averageLabel }
        var ratingsLabel: GlassLabel? { target.ratingsLabel }
    }
}
#endif
