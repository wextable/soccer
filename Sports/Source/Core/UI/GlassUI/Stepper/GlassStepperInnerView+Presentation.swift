//
//  GlassStepperInnerViewModel.swift
//  GlassUI
//
//  Created by Alex Johnson on 7/21/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassStepperInnerView.Model {
    var mainButtonHidden: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return false
        case .stepper:
            return false
        }
    }

    var mainButtonTitle: String {
        switch self {
        case .circlePlus:
            return ""
        case .pill(let label, _, _, _, _, _):
            return label
        case .stepper(let label, _, _, _, _, _, _, _):
            return label
        }
    }

    var mainButtonUserInteractionEnabled: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return true
        case .stepper:
            return true
        }
    }

    func mainButtonFont(for size: GlassStepperInnerView.StepperStyle) -> UIFont {
        switch self {
        case .circlePlus:
            return size.normalButtonFont
        case .pill:
            return size.normalButtonFont
        case .stepper(_, let shrinkLabelFont, _, _, _, _, _, _):
            return shrinkLabelFont ? size.shrunkenButtonFont : size.normalButtonFont
        }
    }

    func buttonIconSize(for style: GlassStepperView.StepperStyle) -> GlassIcon.Size {
        switch (self, style) {
        case (.circlePlus, .small):
            return .size16
        case (.circlePlus, .large):
            return .size32
        case (_, .small):
            return .size16
        case (_, .large):
            return .size24
        }
    }

    var incrementButtonTitle: String {
        switch self {
        case .circlePlus:
            return "Add"
        default:
            return ""
        }
    }

    var incrementButtonHidden: Bool {
        switch self {
        case .circlePlus:
            return false
        case .pill:
            return true
        case .stepper:
            return false
        }
    }

    var incrementButtonEnabled: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return true
        case .stepper(_, _, let enableIncrement, _, _, _, _, _):
            return enableIncrement
        }
    }

    var incrementButtonLeadingEdgeConstraintActive: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return false
        case .stepper:
            return false
        }
    }

    var incrementButtonWidthConstraintWithTitleActive: Bool {
        switch self {
        case .circlePlus:
            return true
        default:
            return false
        }
    }

    var incrementButtonWidthConstraintWithoutTitleActive: Bool {
        switch self {
        case .circlePlus:
            return false
        default:
            return true
        }
    }

    var decrementButtonHidden: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return true
        case .stepper:
            return false
        }
    }

    var decrementButtonEnabled: Bool {
        switch self {
        case .circlePlus:
            return true
        case .pill:
            return true
        case .stepper(_, _, _, let enableDecrement, _, _, _, _):
            return enableDecrement
        }
    }

    var expandedWidthConstraintActive: Bool {
        switch self {
        case .circlePlus:
            return false
        case .pill(_, let fitContent, _, _, _, _):
            return !fitContent
        case .stepper:
            return true
        }
    }

    var fitContentContstraintActive: Bool {
        switch self {
        case .circlePlus:
            return false
        case .pill(_, let fitContent, _, _, _, _):
            return fitContent
        case .stepper:
            return false
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .circlePlus(let accessibilityLabel, _, _, _):
            return accessibilityLabel
        case .pill(_, _, let accessibilityLabel, _, _, _):
            return accessibilityLabel
        case .stepper(_, _, _, _, _, let accessibilityLabel, _, _):
            return accessibilityLabel
        }
    }

    var debounceType: GlassStepperInnerView.DebounceType {
        switch self {
        case .circlePlus(_, let debounceDueTime, _, _):
            return debounceDueTime > 0 ? .enabled(dueTime: debounceDueTime) : .disabled
        case .pill(_, _, _, let debounceDueTime, _, _):
            return debounceDueTime > 0 ? .enabled(dueTime: debounceDueTime) : .disabled
        case .stepper(_, _, _, _, let debounceDueTime, _, _, _):
            return debounceDueTime > 0 ? .enabled(dueTime: debounceDueTime) : .disabled
        }
    }

    var accessibilityTraits: UIAccessibilityTraits {
        guard mainButtonUserInteractionEnabled else { return .none }
//        if mainButtonTitle.asInt() != .none
//            && expandedWidthConstraintActive
//            && incrementButtonHidden == false {
//            return .none
//        }
        return .button
    }

    var incrementButtonAccessibilityHint: String {
        guard incrementButtonTitle.isEmpty else {
            return ""
        }
        switch self {
        case .circlePlus(_, _, let accessibilityLabel, _):
            return accessibilityLabel
        case .pill(_, _, _, _, let accessibilityLabel, _):
            return accessibilityLabel
        case .stepper(_, _, _, _, _, _, let accessibilityLabel, _):
            return accessibilityLabel
        }
    }

    var decrementButtonAccessibilityHint: String {
        switch self {
        case .circlePlus(_, _, _, let accessibilityLabel):
            return accessibilityLabel
        case .pill(_, _, _, _, _, let accessibilityLabel):
            return accessibilityLabel
        case .stepper(_, _, _, _, _, _, _, let accessibilityLabel):
            return accessibilityLabel
        }
    }
}

extension GlassStepperView.StepperStyle {
    var expandedWidth: CGFloat {
        switch self {
        case .small:
            return 120
        case .large:
            return 164
        }
    }

    var height: CGFloat {
        switch self {
        case .small:
            return 32
        case .large:
            return 40
        }
    }

    var normalButtonFont: UIFont {
        switch self {
        case .large:
            return GlassFont.subheading1().uiFont
        case .small:
            return GlassFont.subheading2().uiFont
        }
    }

    var shrunkenButtonFont: UIFont {
        switch self {
        case .large:
            return GlassFont.body2().uiFont
        case .small:
            return GlassFont.captionRegular().uiFont
        }
    }
}

extension GlassStepperView.StepperType {

    var appearance: LDViewAppearance {
        switch self {
        case .primary:
            return .filledBlue
        case .secondary:
            return .outlinedGray1
        }
    }

    var normalButtonText: GlassColor {
        switch self {
        case .primary:
            return .gray00
        case .secondary:
            return .gray200
        }
    }

    var highlightedButtonText: GlassColor {
        .gray00
    }

    var highlightedButtonBackground: GlassColor {
        switch self {
        case .primary:
            return .blue130
        case .secondary:
            return .gray200
        }
    }

    var disabledButtonText: GlassColor {
        switch self {
        case .primary:
            return .blue160
        case .secondary:
            return .gray100
        }
    }
}
