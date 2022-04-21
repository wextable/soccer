//
//  GlassProductListCenterInfoView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/11/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassProductList {
    public struct CenterInfoModel {
        var leftText: NSAttributedString?
        var leftTextAccessibilityLabel: String?
        var rightText: NSAttributedString?
        var rightTextAccessibilityLabel: String?
        var disableAccessibility: Bool

        public init(leftText: NSAttributedString? = nil,
                    leftTextAccessibilityLabel: String? = nil,
                    rightText: NSAttributedString? = nil,
                    rightTextAccessibilityLabel: String? = nil,
                    disableAccessibility: Bool = false) {
            self.leftText = leftText
            self.leftTextAccessibilityLabel = leftTextAccessibilityLabel
            self.rightText = rightText
            self.rightTextAccessibilityLabel = rightTextAccessibilityLabel
            self.disableAccessibility = disableAccessibility
        }
    }

    public class CenterInfoView: BaseView {
        public var model: CenterInfoModel {
            didSet { applyModel() }
        }

        private let leftLabel:GlassLabel = {
            let label = GlassLabel(style: .captionRegular)
            label.textColor = GlassColor.gray140.uiColor
            label.isAccessibilityElement = true
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            return label
        }()

        private let rightLabel:GlassLabel = {
            let label = GlassLabel(style: .captionRegular)
            label.textColor = GlassColor.gray140.uiColor
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.setContentHuggingPriority(.requiredCompliant, for: .horizontal)
            label.isAccessibilityElement = true
            return label
        }()

        init(model: CenterInfoModel = CenterInfoModel()) {
            self.model = model
            super.init(frame: .zero)
            applyModel()
        }

        public override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()
            self.addAutoLayoutSubview(leftLabel)
            self.addAutoLayoutSubview(rightLabel)
        }

        public override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()
            NSLayoutConstraint.activate([
                leftLabel.topAnchor.constraint(equalTo: topAnchor),
                leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                leftLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                rightLabel.topAnchor.constraint(equalTo: topAnchor),
                rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                rightLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                leftLabel.trailingAnchor.constraint(greaterThanOrEqualTo: rightLabel.leadingAnchor,
                                                    constant: -GlassSpacing.xSmall)
            ])
        }

        private func applyModel() {
            leftLabel.attributedText = model.leftText
            rightLabel.attributedText = model.rightText

            if model.disableAccessibility {
                disableAccessibility()
            } else {
                leftLabel.isAccessibilityElement = (model.leftText != nil)
                rightLabel.isAccessibilityElement = (model.rightText != nil)
                leftLabel.accessibilityLabel = model.leftTextAccessibilityLabel
                rightLabel.accessibilityLabel = model.rightTextAccessibilityLabel
            }
        }

        private func disableAccessibility() {
            leftLabel.isAccessibilityElement = false
            rightLabel.isAccessibilityElement = false
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassProductList.CenterInfoView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList.CenterInfoView
        var leftLabel: GlassLabel { target.leftLabel }
        var rightLabel: GlassLabel { target.leftLabel }
    }
}
#endif
