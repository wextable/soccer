//
//  GlassProductListTopInfoView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/3/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassProductList {
    public struct TopInfoModel {
        var name: String?
        var details: String?
        var price: PriceModel?
        var disableAccessibility: Bool
        var isCloseButtonHidden: Bool = false
        var restriction: NSAttributedString?

        public init(restriction: NSAttributedString? = nil,
                    name: String? = nil,
                    details: String? = nil,
                    price: PriceModel? = nil,
                    disableAccessibility: Bool = false,
                    isCloseButtonHidden: Bool = false) {
            self.name = name
            self.details = details
            self.price = price
            self.disableAccessibility = disableAccessibility
            self.isCloseButtonHidden = isCloseButtonHidden
            self.restriction = restriction
        }

        var shouldHidePricingView: Bool {
            price == nil
        }

        var shouldHideCloseButton: Bool {
            price != nil || isCloseButtonHidden
        }

        var shouldHideNameLabel: Bool {
            name == nil
        }

        var shouldHideSecondaryLabel: Bool {
            details == nil
        }

        var shouldHideRestrictionLabel: Bool {
            restriction == nil
        }
    }

    public class TopInfoView: BaseView {
        public var model: TopInfoModel {
            didSet { applyModel() }
        }

        private let closeButton: GlassIconButton = {
            let button = GlassIconButton(icon: GlassIcon.close)
            button.customEnabledBackgroundColor = GlassColor.gray00
            button.customHighlightedBackgroundColor = GlassColor.gray00
            button.customEnabledForegroundColor = GlassColor.gray200
            return button
        }()

        private let pricingView = PriceView()
        private let restrictionLabel = GlassLabel(style: .captionRegular)
        private let nameLabel = GlassLabel(style: .captionRegular)
        private let secondaryLabel = GlassLabel(style: .captionRegular)

        private let stackView = UIStackView(axis: .horizontal)
        private let vStack = UIStackView(axis: .vertical)

        let textBoxLayoutGuide = UILayoutGuide()

        init(model: TopInfoModel = TopInfoModel()) {
            self.model = model
            super.init(frame: .zero)
            closeButton.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
            applyModel()
        }

        public override func constructView() {
            super.constructView()
            addLayoutGuide(textBoxLayoutGuide)
            stackView.alignment = .top
            stackView.distribution = .fill

            nameLabel.textColor = GlassColor.gray140.uiColor
        }

        public override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()
            vStack.addArrangedSubview(restrictionLabel)
            vStack.addArrangedSubview(nameLabel)
            vStack.addArrangedSubview(secondaryLabel)
            stackView.addArrangedSubview(vStack)
            stackView.addArrangedSubview(pricingView)
            nameLabel.numberOfLines = 3
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.isAccessibilityElement = true
            secondaryLabel.isAccessibilityElement = true
            stackView.addArrangedSubview(closeButton)

            addAutoLayoutSubview(stackView)
        }

        public override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            pricingView.setContentHuggingPriority(.requiredCompliant, for: .horizontal)
            NSLayoutConstraint.activate([
                stackView.constraints(pinningTo: self),
                restrictionLabel.constraints(pinningInside: textBoxLayoutGuide),
                nameLabel.constraints(pinningInside: textBoxLayoutGuide),
                secondaryLabel.constraints(pinningInside: textBoxLayoutGuide)
            ])
        }

        private func applyModel() {
            model.price.map { pricingView.model = $0 }
            pricingView.isHidden = model.shouldHidePricingView

            closeButton.isHidden = model.shouldHideCloseButton

            nameLabel.text = model.name
            nameLabel.isHidden = model.shouldHideNameLabel

            secondaryLabel.text = model.details
            secondaryLabel.isHidden = model.shouldHideSecondaryLabel

            restrictionLabel.attributedText = model.restriction
            restrictionLabel.isHidden = model.shouldHideRestrictionLabel

            if model.disableAccessibility { disableAccessibility() }
        }

        private func disableAccessibility() {
            nameLabel.isAccessibilityElement = false
            secondaryLabel.isAccessibilityElement = false
            pricingView.disableAccessibility()
        }

        @objc func didPressCloseButton() {

        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassProductList.TopInfoView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList.TopInfoView
        var nameLabel: GlassLabel { target.nameLabel }
        var secondaryLabel: GlassLabel { target.secondaryLabel }
        var pricingView: GlassProductList.PriceView { target.pricingView }
    }
}
#endif
