//
//  GlassProductList+InfoView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

protocol InfoViewDelegate: AnyObject {
    func didTapLeft(sender: GlassProductList.InfoView)
    func didTapRight(sender: GlassProductList.InfoView)
    func didTapIncrement(sender: GlassProductList.InfoView)
    func didTapDecrement(sender: GlassProductList.InfoView)
    func didTapChange(sender: GlassProductList.InfoView, delta: Int)
}

extension GlassProductList {

    class InfoView: BaseView, BottomInfoViewDelegate {

        public var model: InfoModel? {
            didSet { applyModel() }
        }

        weak var delegate: InfoViewDelegate?

        let topView: TopInfoView = TopInfoView()

        var centerStack: UIStackView = {
            let stackview = UIStackView(axis: .vertical)
            stackview.spacing = GlassSpacing.xSmall
            stackview.distribution = .fill
            stackview.alignment = .fill
            stackview.translatesAutoresizingMaskIntoConstraints = false

            return stackview
        }()

        var discountStack: UIStackView = {
            let stackView = UIStackView(axis: .vertical)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = .init(top: GlassSpacing.small,
                                                       leading: 0,
                                                       bottom: GlassSpacing.small,
                                                       trailing: 0)
            return stackView
        }()

        var carePlanStack: UIStackView = {
            let stackView = UIStackView(axis: .vertical)
            stackView.spacing = GlassSpacing.small
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = .init(top: GlassSpacing.small,
                                                       leading: 0,
                                                       bottom: GlassSpacing.small,
                                                       trailing: 0)
            return stackView
        }()

        public var carePlanTitle: GlassLabel = {
            let label = GlassLabel(style: .subheading1)
            label.text = "Add-on services"
            return label
        }()

        private let bottomView: BottomInfoView

        var stepperAddTitle: String {
            get { bottomView.stepperAddTitle }
            set { bottomView.stepperAddTitle = newValue }
        }

        public var stepperActivationGroup: GlassStepperView.ActivationGroup? {
            get { bottomView.stepperActivationGroup }
            set { bottomView.stepperActivationGroup = newValue }
        }

        private var bottomSpacingConstraint: NSLayoutConstraint?

        public init(stepperAddTitle: String = "",
                    stepperStyle: GlassStepperView.StepperStyle = .small,
                    stepperType: GlassStepperView.StepperType = .secondary,
                    model: InfoModel? = nil) {
            self.bottomView = BottomInfoView(stepperAddTitle: stepperAddTitle,
                                             stepperStyle: stepperStyle,
                                             stepperType: stepperType)
            self.model = model

            super.init(frame: .zero)

            applyModel()
        }

        override func constructView() {
            super.constructView()
            bottomView.delegate = self
        }

        override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()

            addAutoLayoutSubview(topView)
            addAutoLayoutSubview(centerStack)
            addAutoLayoutSubview(discountStack)
            addAutoLayoutSubview(carePlanStack)
            addAutoLayoutSubview(bottomView)
        }

        override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            bottomSpacingConstraint = bottomView.topAnchor.constraint(
                greaterThanOrEqualTo: centerStack.bottomAnchor,
                constant: model?.bottomSpacing ?? .zero
            )

            NSLayoutConstraint.activate([
                topView.leadingAnchor.constraint(equalTo: leadingAnchor),
                topView.trailingAnchor.constraint(equalTo: trailingAnchor),
                topView.topAnchor.constraint(equalTo: topAnchor),

                centerStack.topAnchor.constraint(equalTo: topView.textBoxLayoutGuide.bottomAnchor,
                                                 constant: GlassSpacing.xSmall),
                centerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                centerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                discountStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                discountStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                discountStack.topAnchor.constraint(equalTo: centerStack.bottomAnchor),
                carePlanStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                carePlanStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                carePlanStack.topAnchor.constraint(equalTo: discountStack.bottomAnchor),

                bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
                bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomSpacingConstraint!,
                bottomView.topAnchor.constraint(greaterThanOrEqualTo: carePlanStack.bottomAnchor),
                bottomView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        private func applyModel() {
            guard let model = model else {
                return
            }
            topView.model = model.topInfoModel

            centerStack.subviews.forEach{ $0.removeFromSuperview() }
            centerStack.removeAllArrangedSubviews()
            if let centerModel = model.centerInfoModel {
                for centerModel in centerModel {
                    centerStack.addArrangedSubview(GlassProductList.CenterInfoView(model: centerModel))
                }
                centerStack.isHidden = false
            } else {
                centerStack.isHidden = true
            }

            discountStack.subviews.forEach{ $0.removeFromSuperview() }
            discountStack.removeAllArrangedSubviews()
            if let discountModel = model.discountInfoModel {
                for discountModel in discountModel {
                    let label = GlassProductList.makeDiscountLabel(model: discountModel)
                    discountStack.addArrangedSubview(label)
                }
                discountStack.isHidden = false
            } else {
                discountStack.isHidden = true
            }

            carePlanStack.subviews.forEach{ $0.removeFromSuperview() }
            carePlanStack.removeAllArrangedSubviews()
            if let carePlanModel = model.carePlanModel, !carePlanModel.isEmpty {
                carePlanStack.addArrangedSubview(carePlanTitle)

                for carePlanModel in carePlanModel {
                    let stackView = GlassProductList.makeCarePlanRow(model: carePlanModel)
                    carePlanStack.addArrangedSubview(stackView)
                    stackView.leadingAnchor.constraint(equalTo: carePlanStack.leadingAnchor).isActive = true
                    stackView.trailingAnchor.constraint(equalTo: carePlanStack.trailingAnchor).isActive = true
                }
                carePlanStack.isHidden = false
            } else {
                carePlanStack.isHidden = true
            }

            bottomView.model = model.bottomInfoModel

            bottomSpacingConstraint?.constant = model.bottomSpacing
        }

        // MARK: - Delegates
        func didTapLeft(sender: GlassProductList.BottomInfoView) {
            delegate?.didTapLeft(sender: self)
        }

        func didTapRight(sender: GlassProductList.BottomInfoView) {
            delegate?.didTapRight(sender: self)
        }

        func didTapIncrement(sender: GlassProductList.BottomInfoView) {
            delegate?.didTapIncrement(sender: self)
        }

        func didTapDecrement(sender: GlassProductList.BottomInfoView) {
            delegate?.didTapDecrement(sender: self)
        }

        func didTapChange(sender: GlassProductList.BottomInfoView, delta: Int) {
            delegate?.didTapChange(sender: self, delta: delta)
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassProductList.InfoView {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList.InfoView
        var stepper: GlassStepperView { target.bottomView.testHooks.stepper }
        var topView: GlassProductList.TopInfoView {
            target.topView
        }
    }
}
#endif
