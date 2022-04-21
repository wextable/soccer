//
//  GlassProductList.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public typealias ImageConfigurator = ((UIImageView) -> Void)

public protocol GlassProductListDelegate: AnyObject {
    func didTapIncrement(sender: GlassProductList)
    func didTapDecrement(sender: GlassProductList)
    func didTapCheckbox(sender: GlassProductList)
    func didTapLeft(sender: GlassProductList)
    func didTapRight(sender: GlassProductList)
    func didTapChange(sender: GlassProductList, delta: Int)
}

public extension GlassProductListDelegate {
    func didTapCheckbox(sender: GlassProductList) { }
    func didTapLeft(sender: GlassProductList) { }
    func didTapRight(sender: GlassProductList) { }
    func didTapChange(sender: GlassProductList, delta: Int) { }
}

/// The standard vertical list for displaying product information.
///
/// # Reference
/// [Zeplin](https://zpl.io/2G0561E)
public final class GlassProductList: BaseView, InfoViewDelegate {
    static let infoViewHeight: CGFloat = 96
    func didTapLeft(sender: InfoView) {
        delegate?.didTapLeft(sender: self)
    }

    func didTapRight(sender: InfoView) {
        delegate?.didTapRight(sender: self)
    }

    func didTapIncrement(sender: InfoView) {
        delegate?.didTapIncrement(sender: self)
    }

    func didTapDecrement(sender: InfoView) {
        delegate?.didTapDecrement(sender: self)
    }

    func didTapChange(sender: InfoView, delta: Int) {
        delegate?.didTapChange(sender: self, delta: delta)
    }

    public enum ListStyle {
        case cart(
            name: String?,
            details: String?,
            price: PriceModel?,
            leftButtonText: String?,
            leftButtonAction: (() -> Void)?,
            stepperModel: GlassStepperView.Model?,
            centerContent: [CenterInfoModel]? = nil
        )

        case cartSavedForLater(
            name: String?,
            details: String?,
            price: PriceModel?,
            rightButtonText: String?,
            rightButtonAction: (() -> Void)?,
            centerContent: [CenterInfoModel]? = nil
        )

        case details(
            name: String?,
            details: String?,
            price: PriceModel?,
            centerContent: [CenterInfoModel]? = nil,
            discountContent: [DiscountInfoModel]? = nil
        )

        case detailsEditOrder(
            name: String?,
            details: String?,
            price: PriceModel?,
            leftButtonText: String?,
            leftButtonAccessibilityLabel: String? = nil,
            leftButtonAction: (() -> Void)?,
            stepperModel: GlassStepperView.Model?,
            centerContent: [CenterInfoModel]? = nil,
            discountContent: [DiscountInfoModel]? = nil,
            carePlanContent: [CarePlanModel]? = nil
        )

        case review(
            name: String?,
            details: String?,
            price: PriceModel?,
            centerContent: [CenterInfoModel]? = nil
        )

        case snapshot(
                name: String?,
                details: String?,
                price: PriceModel?,
                leftButtonText: String?,
                leftButtonAction: (() -> Void)?,
                stepperModel: GlassStepperView.Model?,
                centerContent: [CenterInfoModel]? = nil
        )

        case restricted(
                restriction : NSAttributedString?,
                name: NSAttributedString?,
                details: String?,
                price: PriceModel?,
                leftButtonText: String?,
                leftButtonAction: (() -> Void)?,
                stepperModel: GlassStepperView.Model?,
                centerContent: [CenterInfoModel]? = nil
        )

        case dualOptioned(
                name: String?,
                details: String?,
                price: PriceModel?,
                leftButtonText: String?,
                leftButtonAction: (() -> Void)?,
                rightButtonText: String?,
                rightButtonAction: (() -> Void)?,
                centerContent: [CenterInfoModel]? = nil
             )

        var isEditing: Bool {
            switch self {
            case .cart:
                return false
            case .cartSavedForLater:
                return false
            case .details:
                return false
            case .detailsEditOrder:
                return true
            case .review:
                return true
            case .snapshot:
                return false
            case .restricted:
                return false
            case .dualOptioned:
                return false
            }
        }

        var infoModel: InfoModel {
            return InfoModel(topInfoModel: self.topInfoView,
                             centerInfoModels: self.centerInfoModels,
                             discountInfoModels: self.discountInfoModels,
                             carePlanModel: self.carePlanModels,
                             bottomInfoModel: self.bottomInfoView)
        }

        var topInfoView: TopInfoModel {
            switch self {
            case .cart(name: let name,
                       details: let details,
                       price: let price,
                       leftButtonText: _,
                       leftButtonAction: _,
                       stepperModel: _,
                       centerContent: _):
                return TopInfoModel(name: name, details: details, price: price)

            case .cartSavedForLater(name: let name,
                                    details: let details,
                                    price: _,
                                    rightButtonText: _,
                                    rightButtonAction: _,
                                    centerContent: _):
                return TopInfoModel(name: name, details: details, price: nil)

            case .details(name: let name,
                          details: let details,
                          price: let price,
                          centerContent: _,
                          discountContent: _):

                return TopInfoModel(name: name, details: details, price: price)

            case .detailsEditOrder(name: let name,
                                   details: let details,
                                   price: let price,
                                   leftButtonText: _,
                                   leftButtonAccessibilityLabel: _,
                                   leftButtonAction: _,
                                   stepperModel: _,
                                   centerContent: _,
                                   discountContent: _,
                                   carePlanContent: _):
                return TopInfoModel(name: name, details: details, price: price, disableAccessibility: true)

            case .review(name: let name,
                         details: let details,
                         price: let price,
                         centerContent: _):
                return TopInfoModel(name: name, details: details, price: price)

            case .snapshot(name: let name,
                           details: let details,
                           price: _,
                           leftButtonText: _,
                           leftButtonAction: _,
                           stepperModel: _,
                           centerContent: _):
                return TopInfoModel(name: name,
                                    details: details,
                                    price: nil)

            case .restricted(restriction: let restriction,
                              name: _,
                              details: let details,
                              price: _,
                              leftButtonText: _,
                              leftButtonAction: _,
                              stepperModel: _,
                              centerContent: _):
                return TopInfoModel(restriction: restriction,
                                    details: details,
                                    price: nil)

            case .dualOptioned(name: let name,
                               details: let details,
                               price: let price,
                               leftButtonText: _,
                               leftButtonAction: _,
                               rightButtonText: _,
                               rightButtonAction: _,
                               centerContent: _):
            return TopInfoModel(name: name,
                                details: details,
                                price: price)
            }
        }

        var centerInfoModels: [CenterInfoModel]? {
            switch self {
            case .cart(name: _,
                       details: _,
                       price: _,
                       leftButtonText: _,
                       leftButtonAction: _,
                       stepperModel: _,
                       centerContent: let centerModels):
                return centerModels

            case .cartSavedForLater(name: _,
                                    details: _,
                                    price: _,
                                    rightButtonText: _,
                                    rightButtonAction: _,
                                    centerContent: let centerModels):
                return centerModels

            case .details(name: _,
                          details: _,
                          price: _,
                          centerContent: let centerModels,
                          discountContent: _):
                          return centerModels

            case .detailsEditOrder(name: _,
                                   details: _,
                                   price: _,
                                   leftButtonText: _,
                                   leftButtonAccessibilityLabel: _,
                                   leftButtonAction: _,
                                   stepperModel: _,
                                   centerContent: let centerModels,
                                   discountContent: _,
                                   carePlanContent: _):
                                   return centerModels

            case .review(name: _,
                         details: _,
                         price: _,
                         centerContent: let centerModels):
                         return centerModels

            case .snapshot(name: _,
                           details: _,
                           price: let price,
                           leftButtonText: _,
                           leftButtonAction: _,
                           stepperModel: _,
                           centerContent: let centerModels):
                guard let price = price else { return centerModels }
                var prependWithPrice: [CenterInfoModel]? = [.init(leftText: price.primaryPrice,
                                                                  rightText: nil)]
                prependWithPrice?.append(contentsOf: centerModels ?? [])
                return prependWithPrice

            case .restricted(restriction: _,
                             name: let name,
                             details: _,
                             price: _,
                             leftButtonText: _,
                             leftButtonAction: _,
                             stepperModel: _,
                             centerContent: let centerModels):
                guard let name = name else { return centerModels }
                var prependWithPrice: [CenterInfoModel]? = [.init(leftText: name,
                                                                  rightText: nil)]
                prependWithPrice?.append(contentsOf: centerModels ?? [])
                return prependWithPrice

            case .dualOptioned(name: _,
                               details: _,
                               price: _,
                               leftButtonText: _,
                               leftButtonAction: _,
                               rightButtonText: _,
                               rightButtonAction: _,
                               centerContent: let centerModels):
                return centerModels
            }
        }

        var discountInfoModels: [DiscountInfoModel]? {
            switch self {
            case .details(name: _,
                          details: _,
                          price: _,
                          centerContent: _,
                          discountContent: let discountModels):
                          return discountModels

            case .detailsEditOrder(name: _,
                                   details: _,
                                   price: _,
                                   leftButtonText: _,
                                   leftButtonAccessibilityLabel: _,
                                   leftButtonAction: _,
                                   stepperModel: _,
                                   centerContent: _,
                                   discountContent: let discountModels,
                                   carePlanContent: _):
                                   return discountModels

            default:
                return nil
            }
        }

        var carePlanModels: [CarePlanModel]? {
            switch self {
            case .detailsEditOrder(name: _,
                                   details: _,
                                   price: _,
                                   leftButtonText: _,
                                   leftButtonAccessibilityLabel: _,
                                   leftButtonAction: _,
                                   stepperModel: _,
                                   centerContent: _,
                                   discountContent: _,
                                   carePlanContent: let carePlanModels):
                                   return carePlanModels

            default:
                return nil
            }
        }

        var bottomInfoView: BottomInfoModel {
            switch self {
            case .cart(name: _,
                       details: _,
                       price: _,
                       leftButtonText: let leftButtonText,
                       leftButtonAction: let leftButtonAction,
                       stepperModel: let stepperModel,
                       centerContent: _):
                return BottomInfoModel(leftButtonText: leftButtonText,
                                       leftButtonAction: leftButtonAction,
                                       rightButtonText: nil,
                                       rightButtonAction: nil,
                                       stepperModel: stepperModel,
                                       priceModel: nil)

            case .cartSavedForLater(name: _,
                                    details: _,
                                    price: let price,
                                    rightButtonText: let rightButtonText,
                                    rightButtonAction: let rightButtonAction,
                                    centerContent: _):
                return BottomInfoModel(leftButtonText: nil,
                                       leftButtonAction: nil,
                                       rightButtonText: rightButtonText,
                                       rightButtonAction: rightButtonAction,
                                       stepperModel: nil,
                                       priceModel: price)

            case .details(name: _,
                          details: _,
                          price: _,
                          centerContent: _,
                          discountContent: _):
                return BottomInfoModel(leftButtonText: nil,
                                       leftButtonAction: nil,
                                       rightButtonText: nil,
                                       rightButtonAction: nil,
                                       stepperModel: nil,
                                       priceModel: nil)

            case .detailsEditOrder(name: _,
                                   details: _,
                                   price: _,
                                   leftButtonText: let leftButtonText,
                                   leftButtonAccessibilityLabel: let leftButtonAccessibilityLabel,
                                   leftButtonAction: let leftButtonAction,
                                   stepperModel: let stepperModel,
                                   centerContent: _,
                                   discountContent: _,
                                   carePlanContent: _):
                    return BottomInfoModel(leftButtonText: leftButtonText,
                                           leftButtonAccessibilityLabel: leftButtonAccessibilityLabel,
                                           leftButtonAction: leftButtonAction,
                                           rightButtonText: nil,
                                           rightButtonAction: nil,
                                           stepperModel: stepperModel,
                                           priceModel: nil)

            case .review(name: _,
                         details: _,
                         price: _,
                         centerContent: _):
                return BottomInfoModel(leftButtonText: nil,
                                       leftButtonAction: nil,
                                       rightButtonText: nil,
                                       rightButtonAction: nil,
                                       stepperModel: nil,
                                       priceModel: nil)

            case .snapshot(name: _,
                           details: _,
                           price: _,
                           leftButtonText: let leftButtonText,
                           leftButtonAction: let leftButtonAction,
                           stepperModel: let stepperModel,
                           centerContent: _):
                return BottomInfoModel(leftButtonText: leftButtonText,
                                       leftButtonAction: leftButtonAction,
                                       rightButtonText: nil,
                                       rightButtonAction: nil,
                                       stepperModel: stepperModel,
                                       priceModel: nil,
                                       isStepperRightAligned: false)

            case .restricted(restriction: _,
                             name: _,
                             details: _,
                             price: _,
                             leftButtonText: let leftButtonText,
                             leftButtonAction: let leftButtonAction,
                             stepperModel: let stepperModel,
                             centerContent: _):
                return BottomInfoModel(leftButtonText: leftButtonText,
                                       leftButtonAction: leftButtonAction,
                                       rightButtonText: nil,
                                       rightButtonAction: nil,
                                       stepperModel: stepperModel,
                                       priceModel: nil)
            case .dualOptioned(name: _,
                               details: _,
                               price: _,
                               leftButtonText: let leftButtonText,
                               leftButtonAction: let leftButtonAction,
                               rightButtonText: let rightButtonText,
                               rightButtonAction: let rightButtonAction,
                               centerContent: _):
                return BottomInfoModel(leftButtonText: leftButtonText,
                                       leftButtonAction: leftButtonAction,
                                       rightButtonText: rightButtonText,
                                       rightButtonAction: rightButtonAction,
                                       stepperModel: nil,
                                       priceModel: nil)
            }
        }
    }

    /// The model used to populate the product list.
    public var model: Model {
        didSet {
            applyModel()
        }
    }

    public weak var delegate: GlassProductListDelegate?
    public var priceModel: PriceModel? {
        model.listStyle.topInfoView.price
    }
    private let productImageView = ProductImageView()
    private let infoView: InfoView
    private let divider = GlassDivider(style: .tile)
    public let checkBox: GlassCheckbox = {
        let checkbox = GlassCheckbox(frame: CGRect(x: 0, y: 0, width: GlassSpacing.small + GlassSpacing.xxSmall,
                                                   height: GlassSpacing.small + GlassSpacing.xxSmall))
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.isSelected = false
        return checkbox
    }()

    public var isChecked: Bool {
        get {
            return checkBox.isSelected
        }
        set {
            checkBox.isSelected = newValue
        }
    }

    public var stepperAddTitle: String {
        get { infoView.stepperAddTitle }
        set { infoView.stepperAddTitle = newValue }
    }

    public var stepperActivationGroup: GlassStepperView.ActivationGroup? {
        get { infoView.stepperActivationGroup }
        set { infoView.stepperActivationGroup = newValue }
    }

    private let horizontalStackView: UIStackView = {
        let stackview = UIStackView(axis: .horizontal)
        stackview.spacing = GlassSpacing.xSmall
        stackview.distribution = .fillProportionally
        stackview.alignment = .center
        return stackview
    }()

    private let imageFrame: CGFloat

    public init(frame: CGRect = .zero,
                stepperAddTitle: String = "",
                stepperStyle: GlassStepperView.StepperStyle = .small,
                stepperType: GlassStepperView.StepperType = .secondary,
                imageFrame: CGFloat = GlassSpacing.xLarge,
                model: Model = .init()) {

        self.infoView = InfoView(
            stepperAddTitle: stepperAddTitle,
            stepperStyle: stepperStyle,
            stepperType: stepperType
        )
        self.model = model
        self.imageFrame = imageFrame

        super.init(frame: .zero)

        applyModel()
    }

    override public func constructView() {
        super.constructView()

        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        infoView.delegate = self
    }

    override public func constructSubviewHierarchy() {
        super.constructView()

        horizontalStackView.addArrangedSubview(checkBox)
        horizontalStackView.addArrangedSubview(productImageView)
        horizontalStackView.addArrangedSubview(infoView)
        addAutoLayoutSubview(horizontalStackView)
        addAutoLayoutSubview(divider)
    }

    override public func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        productImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            horizontalStackView.constraints(pinningTo: self),
            checkBox.widthAnchor.constraint(equalToConstant: GlassSpacing.small + GlassSpacing.xxSmall),
            checkBox.heightAnchor.constraint(equalToConstant: GlassSpacing.small + GlassSpacing.xxSmall),
            productImageView.widthAnchor.constraint(equalToConstant: imageFrame),
            productImageView.heightAnchor.constraint(equalToConstant: imageFrame),
            productImageView.topAnchor.constraint(greaterThanOrEqualTo: horizontalStackView.topAnchor,
                                                  constant: GlassSpacing.xSmall),
            productImageView.imageView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            infoView.heightAnchor.constraint(greaterThanOrEqualToConstant: GlassProductList.infoViewHeight),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor)
        )
    }
}

extension GlassProductList {

    private func applyModel() {
        checkBox.isHidden = !model.listStyle.isEditing

        model.image.map { productImageView.model = $0 }
        productImageView.isHidden = model.image == nil
        divider.isHidden = model.isDividerHidden

        infoView.model = model.listStyle.infoModel
        infoView.model?.topInfoModel.isCloseButtonHidden = model.isCloseButtonHidden

        if case .snapshot = model.listStyle {
            infoView.model?.bottomSpacing = GlassSpacing.small
        }
    }

    @objc private func didTapCheckBox() {
        delegate?.didTapCheckbox(sender: self)
    }

}

// MARK: - TestHooks

#if DEBUG
extension GlassProductList {
    var testHooks: TestHooks { .init(target: self) }

    struct TestHooks {
        let target: GlassProductList
        var productImageView: ProductImageView { target.productImageView }
        var divider: GlassDivider { target.divider }
        var stepper: GlassStepperView { target.infoView.testHooks.stepper }
        var bottomInfoView: BottomInfoModel? { target.infoView.model?.bottomInfoModel }
        var topInfoView: TopInfoModel? { target.infoView.model?.topInfoModel }
        var infoView: GlassProductList.InfoView { target.infoView }
        var topView: GlassProductList.TopInfoView {
            target.infoView.topView
        }
    }
}
#endif
