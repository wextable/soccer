//
//  GlassToggle.swift
//  GlassUI
//
//  Created by Owen Pierce on 7/7/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Custom switch with two size categories - large and small
///
/// # Discussion
/// - Zeplin Reference - https://zpl.io/25BY080
///
/// # Example
/// ```swift
/// let toggle = GlassToggle(style: .small)
/// toggle.isOn = true
///```
///
public class GlassToggle: BaseControl {

    public enum GlassToggleStyle {
        case large
        case medium
        case small

        var height: CGFloat {
            switch self {
            case .large: return 32.0
            case .medium: return 24.0
            case .small: return 16.0
            }
        }

        var width: CGFloat {
            switch self {
            case .large: return 56.0
            case .medium: return 40.0
            case .small: return 32.0
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .large: return 16.0
            case .medium: return 12.0
            case .small: return 8.0
            }
        }

        var knobDimension: CGFloat {
            switch self {
            case .large: return 24.0
            case .medium: return 22.0
            case .small: return 12.0
            }
        }

        var knobMargin: CGFloat {
            switch self {
            case .large: return GlassSpacing.xxSmall
            case .medium: return GlassSpacing.xxSmall / 4
            case .small: return GlassSpacing.xxSmall / 2
            }
        }
    }

    /// Large or small slider style
    public var style: GlassToggleStyle = .large {
        didSet {
            constructSubviewLayoutConstraints()
        }
    }

    public var isOn: Bool = false {
        didSet {
            manageToggleState()
        }
    }

    override public var isEnabled: Bool {
        didSet {
            manageToggleState()
        }
    }

    let slider = UIView()
    let knob = UIView()
    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggle))

    private var knobAnchorIsOn = NSLayoutConstraint()
    private var knobAnchorIsOff = NSLayoutConstraint()

    private let backgroundColorIsOn = GlassColor.blue100
    private let backgroundColorIsOff = GlassColor.gray100
    private let backgroundColorIsDisabled = GlassColor.gray20

    private let knobColorEnabled = GlassColor.gray00
    private let knobColorDisabled = GlassColor.gray50

    public init(style: GlassToggleStyle = .large) {
        super.init(frame: .zero)
        self.style = style

        accessibilityLabel = "Toggle"
        accessibilityHint = "Double tap to toggle setting"
        construct()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        addAutoLayoutSubview(slider)
        slider.addAutoLayoutSubview(knob)

        addGestureRecognizer(tapGestureRecognizer)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        removeConstraints(constraints)
        knob.removeConstraints(knob.constraints)

        slider.layer.cornerRadius = style.cornerRadius
        slider.clipsToBounds = true
        knob.layer.cornerRadius = style.knobDimension / 2

        knobAnchorIsOn = knob.trailingAnchor.constraint(equalTo: slider.trailingAnchor,
                                                        constant: -style.knobMargin)

        knobAnchorIsOff = knob.leadingAnchor.constraint(equalTo: slider.leadingAnchor,
                                                        constant: style.knobMargin)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: style.height),
            widthAnchor.constraint(equalToConstant: style.width),
            slider.constraints(pinningTo: self),
            knob.heightAnchor.constraint(equalToConstant: style.knobDimension),
            knob.widthAnchor.constraint(equalToConstant: style.knobDimension),
            knob.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
        ])

        manageToggleState()
    }

    @objc public func toggle() {
        if isEnabled {
            isOn = !isOn
            accessibilityValue = String(isOn)
            accessibilityLabel = "Toggle is \(isOn ? "on" : "off")"
            sendActions(for: .valueChanged)
        }
    }

    func manageToggleState() {
        if isEnabled {
            slider.backgroundColor = isOn ? backgroundColorIsOn.uiColor : backgroundColorIsOff.uiColor
            knob.backgroundColor = knobColorEnabled.uiColor
        } else {
            slider.backgroundColor = backgroundColorIsDisabled.uiColor
            knob.backgroundColor = knobColorDisabled.uiColor
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: GlassAnimation.animationTimeShort) {
                self.knobAnchorIsOn.isActive = self.isOn
                self.knobAnchorIsOff.isActive = !self.isOn
                self.layoutIfNeeded()
            }
        }
    }
}
