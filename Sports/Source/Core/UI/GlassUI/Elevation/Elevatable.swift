///
///  Elevatable.swift
///  GlassUI
///
///  Created by Eric Reedy on 12/22/20.
///  Copyright © 2020 Walmart. All rights reserved.
///
// swiftlint:disable double_space

import UIKit

///
/// This protocol is used to configure `UIView` classes with the ability to be configured with appearances and
/// elevation levels derived from the
/// [Living Design Specs](https://app.zeplin.io/project/5e87d2e78e5f6020f1c99106/screen/5f0645cd774a407d05725f5c).
///
/// When conforming to this interface, it is important to adhere to the following practices:
/// 1. Call `updateFromAppearance()` on `didSet` for the `appearance` variable.
/// 2. Call `updateFromElevation()` on `didSet` for the `elevationLevel` variable.
/// 3. Call `updateShadowPath()` from an `override` of the `layoutSubviews()` function.
///
/// These must be done for each adherence, as protocols cannot `override` functions or specify `didSet` hooks.
///
public protocol Elevatable: UIView {
    var appearance: LDViewAppearance { get set }
    var elevationLevel: LDElevationLevel { get set }
}

extension Elevatable {

    ///
    /// Applies all attributes of the current `appearance` to the view.
    ///
    /// - Note: Be sure to call this any time `appearance` is set.
    ///
    func updateFromAppearance() {

        if let backgroundColor = appearance.backgroundColor {
            layer.backgroundColor = backgroundColor.uiColor.cgColor
        }

        if let borderColor = appearance.borderColor {
            layer.borderColor = borderColor.uiColor.cgColor
        }

        layer.borderWidth = appearance.borderWidth
    }

    ///
    /// Applies all attributes of the current `elevationLevel` to the view.
    ///
    /// - Note: Be sure to call this any time `elevationLevel` is set.
    ///
    func updateFromElevation() {
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize    = true
        layer.masksToBounds      = false
        layer.shadowColor        = elevationLevel.shadowColor
        layer.shadowOffset       = elevationLevel.shadowOffset
        layer.shadowOpacity      = elevationLevel.shadowOpacity
        layer.shadowRadius       = elevationLevel.shadowRadius

        updateShadowPath()
    }

    ///
    /// Generates a ShadowPath extended outward from the view, providing a sense of "spread", with which shadows are
    /// often described and configured.  Additionally, if this has been called within a UIKit Animation, a
    /// CABasicAnimation is produced and applied with `duration` and `timingFunctions` set to match.
    ///
    /// - Note: Be sure to call this any time `layoutSubviews()` is called.
    ///
    func updateShadowPath() {

        let shadowPath: UIBezierPath = .init(roundedRect: shadowRect, cornerRadius: layer.cornerRadius)

        let resizeAnimationKey = "bounds.size"
        if let resizeAnimation = layer.animation(forKey: resizeAnimationKey) as? CABasicAnimation
        {
            let shadowPathAnimationKey = "shadowPath"
            let shadowPathAnimation = CABasicAnimation(keyPath: shadowPathAnimationKey)
            shadowPathAnimation.toValue = shadowPath
            shadowPathAnimation.speed = resizeAnimation.speed
            shadowPathAnimation.duration = resizeAnimation.duration
            shadowPathAnimation.fillMode = resizeAnimation.fillMode
            shadowPathAnimation.fromValue = resizeAnimation.fromValue
            shadowPathAnimation.beginTime = resizeAnimation.beginTime
            shadowPathAnimation.timeOffset = resizeAnimation.timeOffset
            shadowPathAnimation.autoreverses = resizeAnimation.autoreverses
            shadowPathAnimation.timingFunction = resizeAnimation.timingFunction
            layer.add(shadowPathAnimation, forKey: shadowPathAnimationKey)
        }

        layer.shadowPath = shadowPath.cgPath
    }

    ///
    /// Calculates and returns the bounding box to be used in updating the `layer.shadowPath`.
    ///
    private var shadowRect: CGRect {

        let shadowRect: CGRect
        if elevationLevel.spread == 0 {
            shadowRect = bounds
        } else {
            let dxy  = -elevationLevel.spread/3
            shadowRect = bounds.insetBy(dx: dxy, dy: dxy)
        }

        return shadowRect
    }
}

///
/// This enum is intented for use in configuring `Elevatable` protocol-conforming classes with filled and outlined
/// appearance
/// variation combinations, as specified in the
/// [Living Design Specs](https://app.zeplin.io/project/5e87d2e78e5f6020f1c99106/screen/5f0645cd774a407d05725f5c).
///
public enum LDViewAppearance: CaseIterable {
    case unspecified
    case filledWhite, filledBlue
    case outlinedBlack1, outlinedBlue1, outlinedGray1
    case outlinedBlack2, outlinedBlue2, outlinedGray2

    public var backgroundColor: GlassColor? {
        switch self {
        case .unspecified: return nil
        case .filledBlue:  return GlassColor.blue100
        default:           return GlassColor.gray00
        }
    }

    public var borderColor: GlassColor? {
        switch self {
        case .outlinedBlack1, .outlinedBlack2: return GlassColor.gray200
        case .outlinedBlue1, .outlinedBlue2:   return GlassColor.blue100
        case .outlinedGray1, .outlinedGray2:   return GlassColor.gray50
        default:                               return nil
        }
    }

    public var borderWidth: CGFloat {
        switch self {
        case .outlinedBlack1, .outlinedBlue1, .outlinedGray1: return 1
        case .outlinedBlack2, .outlinedBlue2, .outlinedGray2: return 2
        default:                                              return 0
        }
    }
}

///
/// This enum is intented for use in configuring `Elevatable` protocol-conforming classes with one of several shadow
/// variations, as specified in the
/// [Living Design Specs](https://app.zeplin.io/project/5e87d2e78e5f6020f1c99106/screen/5f0645cd774a407d05725f5c).
/// A value of .zero will produce no shadow, while higher values each produce larger, more prominent shadows than the
/// last.
/// All values are configured to match the CSS-derived values, as specified.  These values may be manipulated where
/// implemented in order to achieve a more accurate visual match.
///
public enum LDElevationLevel: CaseIterable {
    case zero, one, two, three
}

private extension LDElevationLevel {

    var offset: CGSize {
        switch self {
        case .zero:  return .zero
        case .one:   return .init(width: 0, height: 1)
        case .two:   return .init(width: 0, height: 3)
        case .three: return .init(width: 0, height: 5)
        }
    }

    var radius: CGFloat {
        switch self {
        case .zero:  return 0
        case .one:   return 2
        case .two:   return 5
        case .three: return 10
        }
    }

    var spread: CGFloat {
        switch self {
        case .zero:  return 0
        case .one:   return 1
        case .two:   return 2
        case .three: return 3
        }
    }

    var color: UIColor {
        switch self {
        case .zero: return .clear
        default:    return GlassColor.gray200.uiColor
        }
    }

    var opacity: Float {
        switch self {
        case .zero: return 0
        default:    return 0.15
        }
    }
}

public extension LDElevationLevel {

    var shadowColor: CGColor { color.cgColor }
    var shadowOffset: CGSize { offset }
    var shadowOpacity: Float { opacity * 1.2 }
    var shadowRadius: CGFloat { radius / 2 }
}

#if DEBUG

    extension Elevatable {
        var test_shadowRect: CGRect { shadowRect }
    }

#endif
