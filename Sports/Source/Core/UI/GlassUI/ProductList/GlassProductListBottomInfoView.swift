//
//  GlassProductListBottomInfoView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/3/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

protocol BottomInfoViewDelegate: AnyObject {
    func didTapLeft(sender: GlassProductList.BottomInfoView)
    func didTapRight(sender: GlassProductList.BottomInfoView)
    func didTapIncrement(sender: GlassProductList.BottomInfoView)
    func didTapDecrement(sender: GlassProductList.BottomInfoView)
    func didTapChange(sender: GlassProductList.BottomInfoView, delta: Int)
}

extension GlassProductList {
    public struct BottomInfoModel {
        var leftButtonText: String?
        var leftButtonAccessibilityLabel: String?
        var leftButtonAction: (() -> Void)?
        var rightButtonText: String?
        var rightButtonAction: (() -> Void)?
        var stepperModel: GlassStepperView.Model?
        var priceModel: PriceModel?
        var isStepperRightAligned: Bool

        public init(leftButtonText: String? = nil,
                    leftButtonAccessibilityLabel: String? = nil,
                    leftButtonAction: (() -> Void)? = nil,
                    rightButtonText: String? = nil,
                    rightButtonAction: (() -> Void)? = nil,
                    stepperModel: GlassStepperView.Model? = nil,
                    priceModel: PriceModel? = nil,
                    isStepperRightAligned: Bool = true) {
            self.leftButtonText = leftButtonText
            self.leftButtonAccessibilityLabel = leftButtonAccessibilityLabel
            self.leftButtonAction = leftButtonAction
            self.rightButtonText = rightButtonText
            self.rightButtonAction = rightButtonAction
            self.stepperModel = stepperModel
            self.priceModel = priceModel
            self.isStepperRightAligned = isStepperRightAligned
        }
    }

    class BottomInfoView: BaseView {
        public var model: BottomInfoModel {
            didSet { applyModel() }
        }

        weak var delegate: BottomInfoViewDelegate?

        private let pricingView = PriceView()
        private let leftButton = GlassLinkButton()
        private let rightButton = GlassLinkButton()
        private var stepper: GlassStepperView
        private let leftSpacerView = UIView(frame: .zero)
        private let rightSpacerView = UIView(frame: .zero)

        var stepperAddTitle: String {
            get { stepper.addTitle }
            set { stepper.addTitle = newValue }
        }

        public var stepperActivationGroup: GlassStepperView.ActivationGroup? {
            get { stepper.activationGroup }
            set { stepper.activationGroup = newValue }
        }

        private let stackView: UIStackView = {
            let stackView = UIStackView(axis: .horizontal)
            stackView.alignment = .fill
            return stackView
        }()

        init(stepperAddTitle: String = "",
             stepperStyle: GlassStepperView.StepperStyle = .small,
             stepperType: GlassStepperView.StepperType = .secondary,
             model: BottomInfoModel = BottomInfoModel()) {
            self.stepper = GlassStepperView(style: stepperStyle,
                                            type: stepperType,
                                            tracksIdle: false,
                                            collapsesWhenIdle: false,
                                            addTitle: stepperAddTitle,
                                            idleSuffix: "")
            self.model = model

            super.init(frame: .zero)
            applyModel()
        }

        override func constructView() {
            super.constructView()

            stepper.onIncrement = { [weak self] in self?.increment() }
            stepper.onDecrement = { [weak self] in self?.decrement() }
            stepper.onChange = { [weak self] delta in self?.change(delta) }
        }

        override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()

            stackView.addArrangedSubview(pricingView)
            stackView.addArrangedSubview(leftButton)
            stackView.addArrangedSubview(leftSpacerView)
            stackView.addArrangedSubview(rightButton)
            stackView.addArrangedSubview(stepper)
            stackView.addArrangedSubview(rightSpacerView)

            addAutoLayoutSubview(stackView)
        }

        override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassSpacing.small)
            ])
        }

        @objc func didPressLeftButton() {
            model.leftButtonAction!()
            delegate?.didTapLeft(sender: self)
        }

        @objc func didPressRightButton() {
            model.rightButtonAction!()
            delegate?.didTapRight(sender: self)
        }

        private func increment() {
            delegate?.didTapIncrement(sender: self)
        }

        private func decrement() {
            delegate?.didTapDecrement(sender: self)
        }

        private func change(_ delta: Int) {
            delegate?.didTapChange(sender: self, delta: delta)
        }

        private func applyModel() {
            leftSpacerView.isHidden = true

            if let leftTitle = model.leftButtonText, model.leftButtonAction != nil{
                leftButton.setTitle(leftTitle, for: .normal)
                leftButton.addTarget(self, action: #selector(didPressLeftButton), for: .touchUpInside)
                leftButton.contentHorizontalAlignment = .left
                leftButton.accessibilityLabel = model.leftButtonAccessibilityLabel ?? model.leftButtonText
                leftButton.isHidden = false
                leftSpacerView.isHidden = false
            } else {
                leftButton.isHidden = true
            }

            if let rightTitle = model.rightButtonText, model.rightButtonAction != nil {
                rightButton.setTitle(rightTitle, for: .normal)
                rightButton.addTarget(self, action: #selector(didPressRightButton), for: .touchUpInside)
                rightButton.isHidden = false
                rightButton.contentHorizontalAlignment = .right
                leftSpacerView.isHidden = false
            } else {
                rightButton.isHidden = true
            }

            if let priceModel = model.priceModel {
                pricingView.model = priceModel
                pricingView.isHidden = false
                leftSpacerView.isHidden = false
            } else {
                pricingView.isHidden = true
            }

            if let stepperModel = model.stepperModel {
                stepper.model = stepperModel
                stepper.isHidden = false
                leftSpacerView.isHidden = !model.isStepperRightAligned
                rightSpacerView.isHidden = model.isStepperRightAligned
            } else {
                stepper.isHidden = true
                rightSpacerView.isHidden = true
            }

        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassProductList.BottomInfoView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList.BottomInfoView
        var stepper: GlassStepperView { target.stepper }
        var leftButton: GlassLinkButton { target.leftButton }
    }
}
#endif
