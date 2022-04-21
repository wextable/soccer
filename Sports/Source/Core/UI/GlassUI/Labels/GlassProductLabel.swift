//
//  GlassProductLabel.swift
//  GlassUI
//
//  Created by Owen Pierce on 4/24/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Product labels are unbounded and have no background. They feature an optional icon.
/// # Discussion
/// [Zeplin Reference](https://zpl.io/2vZl3Ln)
/// Don't use text that causes labels to grow beyond 102px in width.
/// Avoid truncating labels.
/// Text should not be in all caps.
public final class GlassProductLabel: BaseView {

    public struct Model {
        public let text: String
        public let icon: GlassIcon?
        public let tintColor: UIColor

        public init(text: String,
                    icon: GlassIcon? = nil,
                    tintColor: UIColor = GlassColor.blue120.uiColor) {
            self.text = text
            self.icon = icon
            self.tintColor = tintColor
        }
    }

    public var model: Model? {
        didSet { applyModel() }
    }

    public var style: GlassLabelStyle {
        didSet {
            label.style = style
        }
    }

    internal let label: GlassLabel = GlassLabel(style: .captionRegular)
    internal let imageView: UIImageView = UIImageView()

    private let mainStackView = UIStackView(axis: .horizontal, alignment: .center)

    public init(model: Model? = nil, style: GlassLabelStyle = .captionRegular) {
        self.model = model
        self.style = style
        super.init(frame: .zero)
        label.style = style
        applyModel()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(label)

        addAutoLayoutSubview(mainStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        imageView.setContentHuggingPriority(.requiredCompliant, for: .horizontal)

        mainStackView.spacing = GlassSpacing.xxSmall
        NSLayoutConstraint.activate(
            mainStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24.0)
                .with(priority: .requiredCompliant),
            mainStackView.constraints(pinningTo: self)
        )
    }

    private func applyModel() {
        label.text = model?.text
        accessibilityLabel = model?.text
        label.textColor = model?.tintColor
        imageView.isHidden = (model?.icon == nil)
        imageView.image = model?.icon?.image(.size12).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = model?.tintColor
    }
}
