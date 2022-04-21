//
//  GlassProductList+CarePlan.swift
//  GlassUI
//
//  Created by Brayden Wilmoth on 8/18/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import Foundation
import UIKit

extension GlassProductList {
    public struct CarePlanModel {
        var icon: GlassIcon?
        var name: NSAttributedString?
        var price: NSAttributedString?

        public init(icon: GlassIcon?, name: NSAttributedString?, price: NSAttributedString? = nil) {
            self.icon = icon
            self.name = name
            self.price = price
        }
    }

    public static func makeCarePlanRow(model: CarePlanModel) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal)
        stackView.spacing = GlassSpacing.xSmall
        stackView.distribution = .fillProportionally
        stackView.alignment = .firstBaseline
        stackView.translatesAutoresizingMaskIntoConstraints = false

        if model.icon != nil {
            if let icon = makeCarePlanIcon(model: model) {
                stackView.addArrangedSubview(icon)
                icon.topAnchor.constraint(equalTo: stackView.topAnchor, constant: GlassSpacing.xxSmall).isActive = true
            }
        }

        stackView.addArrangedSubview(makeCarePlanNameLabelView(model: model))

        if model.price != nil {
            let price = makeCarePlanPriceLabel(model: model)
            stackView.addArrangedSubview(price)
            price.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        }

        return stackView
    }

    public static func makeCarePlanIcon(model: CarePlanModel) -> UIImageView? {
        let icon = model.icon?.imageSize16()
        let imageView = UIImageView.init(image: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: GlassSpacing.small).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    public static func makeCarePlanNameLabelView(model: CarePlanModel) -> UIView {
        let view = UIView()
        let label = makeCarePlanNameLabel(model: model)
        view.addSubview(label)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        return view
    }

    public static func makeCarePlanNameLabel(model: CarePlanModel) -> GlassLabel {
        let label = GlassLabel(style: .captionRegular)
        label.attributedText = model.name
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }

    public static func makeCarePlanPriceLabel(model: CarePlanModel) -> GlassLabel {
        let label = GlassLabel(style: .captionBold)
        if let price = model.price {
            label.attributedText = price
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }
}
