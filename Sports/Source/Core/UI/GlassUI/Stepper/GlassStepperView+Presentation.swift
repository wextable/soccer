//
//  GlassStepperView+Presentation.swift
//  GlassUI
//
//  Created by Alex Johnson on 7/21/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassStepperView.Model {
    func innerModel(isIdle: Bool,
                    accessibilityState: GlassStepperView.AccessibilityState,
                    collapsesWhenIdle: Bool,
                    allowsDecrementAtMin: Bool,
                    allowsIncrementAtMax: Bool,
                    addTitle: String,
                    idleSuffix: String) -> GlassStepperInnerView.Model
    {
        if isEmpty && addTitle != "" {
            if accessibilityState != .interacting {
                if collapsesWhenIdle {
                    return .circlePlus(
                        accessibilityLabel: baseAccessibilityLabel,
                        debounceDueTime: debounceDueTime,
                        incrementButtonAccessibilityLabel: accessibilityModel.incrementButtonLabel,
                        decrementButtonAccessibilityLabel: accessibilityModel.decrementButtonLabel
                    )
                } else {
                    return .pill(label: addTitle,
                                 fitContent: false,
                                 accessibilityLabel: "\(addTitle) \(accessibilityModel.title)",
                                 debounceDueTime: debounceDueTime,
                                 incrementButtonAccessibilityLabel: accessibilityModel.incrementButtonLabel,
                                 decrementButtonAccessibilityLabel: accessibilityModel.decrementButtonLabel)
                }
            }
        } else if accessibilityState == .idle && isIdle {
            let accessibilityLabel = !idleSuffix.isEmpty ?
                "\(baseValue)\(idleSuffix)" :
                inCartAccessibilityLabel(isIdle: isIdle)
            return .pill(label: displayValue(isIdle: true, idleSuffix: idleSuffix),
                         fitContent: collapsesWhenIdle,
                         accessibilityLabel: accessibilityLabel,
                         debounceDueTime: debounceDueTime,
                         incrementButtonAccessibilityLabel: accessibilityModel.incrementButtonLabel,
                         decrementButtonAccessibilityLabel: accessibilityModel.decrementButtonLabel)
        }

        return .stepper(
            label: displayValue(isIdle: false, idleSuffix: ""),
            shrinkLabelFont: (isAtMin && !hidesMinPrefix) || isAtMax,
            enableIncrement: !isAtMax || allowsIncrementAtMax,
            enableDecrement: !isEmpty && (!isAtMin || allowsDecrementAtMin),
            debounceDueTime: debounceDueTime,
            accessibilityLabel: inCartAccessibilityLabel(isIdle: isIdle),
            incrementButtonAccessibilityLabel: accessibilityModel.incrementButtonLabel,
            decrementButtonAccessibilityLabel: accessibilityModel.decrementButtonLabel
        )
    }

    private func displayValue(isIdle: Bool, idleSuffix: String) -> String {
        formattedValue(isIdle: isIdle,
                       idleSuffix: idleSuffix,
                       minPrefix: "stepper.at-min-prefix".localize(),
                       maxPrefix: "stepper.at-max-prefix".localize())
    }

    private func formattedValue(isIdle: Bool, idleSuffix: String, minPrefix: String, maxPrefix: String) -> String {
        if isIdle {
            return baseValue + idleSuffix
        } else if isAtMax {
            return maxPrefix + baseValue
        } else if isAtMin && !hidesMinPrefix {
            return minPrefix + baseValue
        } else {
            return baseValue
        }
    }

    var isEmpty: Bool {
        addOnModel == nil ? value == 0 : addOnModel == nil
    }

    private var baseValue: String {
        if let addOnModel = addOnModel {
            return NSNumber(value: addOnModel.values.first).description
                + addOnModel.valuesSuffix.first
                + " "
                + NSNumber(value: addOnModel.values.last).description
                + addOnModel.valuesSuffix.last
        } else {
            // Note: Using `NSNumber` because it automatically trims trailing 0s:
            return NSNumber(value: value).description + valueSuffix
        }
    }

    private var baseAccessibilityLabel: String {
        if accessibilityModel.useSuffix {
            // "Add to cart {item name}"
           return "\(accessibilityModel.increment) \(accessibilityModel.title)"
        } else {
            // "1 item added to cart"
            return "\(accessibilityModel.title) \(accessibilityModel.increment)"
        }
    }

    private func inCartAccessibilityLabel(isIdle: Bool) -> String {
        let model = accessibilityModel
        if accessibilityModel.useSuffix {
            if isIdle {
                //useQuantityMenu ? "add to cart + 1 in cart, [item name]," : "Add to cart {name}, {quantity} in cart"
                return model.useQuantityMenuTitle ?
                    "\(model.increment), \(baseValue) \(model.collapsed), \(model.title)"
                    : "\(baseAccessibilityLabel), \(baseValue) \(accessibilityModel.collapsed)"
            } else {
                // "1 in cart, double tap to open quantity menu, [item name]" : "Add to cart {name}, {quantity} in cart"
                let label = model.useQuantityMenuTitle ?
                    "\(baseValue) \(model.collapsed), \(model.quantityMenuTitle), \(model.title)"
                    :"\(baseAccessibilityLabel), \(baseValue) \(accessibilityModel.collapsed)"
                return label
            }
        } else {
            return "\(baseValue), \(baseAccessibilityLabel) \(model.collapsed)"
        }
    }
}
