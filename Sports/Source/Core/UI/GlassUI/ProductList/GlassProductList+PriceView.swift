//
//  GlassProductList+PriceView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassProductList {

    /// This class is a subview shown on the GlassProductTile. It displays the pricing information.
    final class PriceView: BaseView {

        var model: PriceModel {
            didSet {
                applyModel()
            }
        }

        private let primaryPriceLabel: UILabel
        private let preDiscountedLabel: UILabel
        private let weightLabel: GlassLabel

        private let mainStackView: UIStackView

        init(model: PriceModel = PriceModel()) {
            self.model = model

            primaryPriceLabel = UILabel()
            primaryPriceLabel.numberOfLines = 2
            primaryPriceLabel.font = GlassFont.subheading1().uiFont
            primaryPriceLabel.lineBreakMode = .byWordWrapping
            primaryPriceLabel.isAccessibilityElement = true
            preDiscountedLabel = UILabel()
            preDiscountedLabel.numberOfLines = 2
            preDiscountedLabel.font = GlassFont.captionBold().uiFont
            preDiscountedLabel.lineBreakMode = .byWordWrapping
            preDiscountedLabel.isAccessibilityElement = true
            weightLabel = GlassLabel(style: .captionRegular)
            weightLabel.isAccessibilityElement = true
            mainStackView = UIStackView(axis: .vertical)
            mainStackView.alignment = .trailing

            super.init(frame: .zero)

            applyModel()
        }

        override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()

            mainStackView.addArrangedSubview(primaryPriceLabel)
            mainStackView.addArrangedSubview(preDiscountedLabel)
            mainStackView.addArrangedSubview(weightLabel)
            addAutoLayoutSubview(mainStackView)
        }

        override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            mainStackView.spacing = GlassSpacing.xxSmall
            NSLayoutConstraint.activate(
                mainStackView.constraints(pinningTo: self)
            )
        }

        private func applyModel() {
            primaryPriceLabel.apply(price: model.primaryPrice, with: model.primaryPriceAccessibilityLabel)

            if model.preDiscountedPrice == nil {
                primaryPriceLabel.textColor = GlassColor.gray160.uiColor
                preDiscountedLabel.isHidden = true
                mainStackView.setCustomSpacing(UIStackView.spacingUseDefault, after: primaryPriceLabel)
                mainStackView.distribution = .fillProportionally
            } else {
                primaryPriceLabel.textColor = GlassColor.green100.uiColor
                preDiscountedLabel.apply(price: model.preDiscountedPrice,
                                         with: model.preDiscountedPriceAccessibilityLabel)
                preDiscountedLabel.isHidden = false
                mainStackView.setCustomSpacing(.zero, after: primaryPriceLabel)
                mainStackView.distribution = .fill
            }

            if model.weightMessage == nil {
                weightLabel.isHidden = true
            } else {
                weightLabel.text = model.weightMessage
                weightLabel.isHidden = false
            }
        }

        func disableAccessibility() {
            primaryPriceLabel.isAccessibilityElement = false
            preDiscountedLabel.isAccessibilityElement = false
            weightLabel.isAccessibilityElement = false
        }
    }
}

private extension UILabel {
    func apply(price: NSAttributedString?, with priceAccessibiltyLabel: String?) {
        attributedText = price
        if let priceAccessibiltyLabel = priceAccessibiltyLabel {
            accessibilityLabel = priceAccessibiltyLabel
            accessibilityValue = price?.string
        } else {
            accessibilityLabel = nil
            accessibilityValue = nil
        }
    }
}
// MARK: - TestHooks

#if DEBUG
extension GlassProductList.PriceView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList.PriceView
        var primaryPriceLabel: UILabel { target.primaryPriceLabel }
        var preDiscountedLabel: UILabel { target.preDiscountedLabel }
        var weightLabel: GlassLabel { target.weightLabel }
    }
}
#endif
