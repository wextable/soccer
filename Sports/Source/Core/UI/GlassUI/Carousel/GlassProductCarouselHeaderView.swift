//
//  GlassProductCarouselHeaderView.swift
//  GlassUI
//
//  Created by John Liedtke on 5/14/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// The standard header view in a product carousel.
///
/// # Reference
/// [Zeplin](https://app.zeplin.io/project/5e913a56086f2c23293ebd03/screen/5ea399e8f6ee31bcc60bee29)
public class GlassProductCarouselHeaderView: BaseCollectionReusableView {

    /// The view model for a carousel header.
    public struct Model {

        /// The title display in the header.
        public let title: NSAttributedString

        /// An optional subtitle to display.
        public let subtitle: String?

        /// The title of the link button.
        public let linkTitle: String?

        /// Use this initializer if GlassProductCarouselHeaderView's title is
        /// a NSAttributedString
        public init(title: NSAttributedString, subtitle: String?, linkTitle: String?) {
            self.title = title
            self.subtitle = subtitle
            self.linkTitle = linkTitle
        }

        /// Use this initializer if GlassProductCarouselHeaderView's title is a String
        /// Default title color, font attributes will be applied
        public init(title: String, subtitle: String?, linkTitle: String?) {
            self.init(title: NSAttributedString.init(string: title,
                                                     attributes: [
                                                        .font: GlassFont.heading().uiFont,
                                                        .foregroundColor: GlassColor.gray200.uiColor
                                                    ]),
                                                    subtitle: subtitle,
                                                    linkTitle: linkTitle
            )
        }
    }

    public var model: Model? {
        didSet { applyViewModel() }
    }

    /// The handler to execute when the link button is pressed.
    public var linkActionHandler: (() -> Void)?

    private let titleLabel: GlassLabel
    private let subtitleLabel: GlassLabel
    private let linkButton: GlassLinkButton

    private let stackView: UIStackView

    public override init(frame: CGRect) {
        titleLabel = GlassLabel()
        subtitleLabel = GlassLabel(style: .captionRegular)
        linkButton = GlassLinkButton()
        stackView = UIStackView()
        super.init(frame: frame)
    }

    public override func constructView() {
        super.constructView()

        stackView.axis = .vertical
        titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.accessibilityTraits = .header
        linkButton.addTarget(self, action: #selector(didTapLinkButton), for: .touchUpInside)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        addAutoLayoutSubview(linkButton)
        addAutoLayoutSubview(stackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        stackView.spacing = GlassSpacing.xxSmall
        linkButton.setContentHuggingPriority(UILayoutPriority.requiredCompliant, for: .horizontal)
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self,
                                  edges: [.leading, .vertical],
                                  insets: .init(top: GlassSpacing.small,
                                                bottom: GlassSpacing.small)),

            linkButton.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            linkButton.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor,
                                                constant: GlassSpacing.mediumSmall),
            linkButton.constraints(pinningTo: self,
                                   edges: .trailing)
        )
    }

    @objc
    private func didTapLinkButton() {
        linkActionHandler?()
    }
}

extension GlassProductCarouselHeaderView {

    private func applyViewModel() {
        titleLabel.attributedText = model?.title
        subtitleLabel.text = model?.subtitle
        subtitleLabel.isHidden = (model?.subtitle ?? "").isEmpty
        linkButton.setTitle(model?.linkTitle, for: .normal)
        linkButton.isHidden = (model?.linkTitle ?? "").isEmpty
    }
}
