//
//  GlassChip.swift
//  GlassUI
//
//  Created by Joshua Mann on 5/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import CoreHaptics
import Foundation
import UIKit

/// Glass chip view for displaying selections in single row and multiline
/// # Discussion
/// [Zeplin Reference](https://zpl.io/2yZNX7y)
///
/// # Example
/// ```swift
/// let multiSelectChip = GlassChip(title: "EXAMPLE", isMultiSelect: true, isSelected: false)
/// ```
public class GlassChip: UIView {

    public enum ChipStyle {
        case medium
        case large
        case xLarge
    }

    private let cornerRadius: CGFloat = 4
    public var unselectedBorderWidth: CGFloat = 1
    public var selectedBorderWidth: CGFloat = 1
    private let enabledBackgroundColor = GlassColor.gray00
    private let disabledBackgroundColor = GlassColor.gray10
    private let unselectedBorderColor = GlassColor.gray80
    private let selectedBorderColor =  GlassColor.gray200
    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var chipStyle: ChipStyle
    private var longPressGestureRecognizer: UILongPressGestureRecognizer
    private lazy var hapticEngine: GlassHapticEngine = {
        let engine = GlassHapticEngine()
        engine.view = self
        return engine
    }()

    public var tapAction: (() -> Void)?

    public var gestureRecognizerEnabled: Bool = true {
        didSet {
            longPressGestureRecognizer.isEnabled = gestureRecognizerEnabled
        }
    }

    public var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    public override var isUserInteractionEnabled: Bool {
        didSet {
            guard oldValue != isUserInteractionEnabled else { return }
            updateUI()
        }
    }

    internal let isMultiSelect: Bool

    /// Disable the selection variable’s update
    internal let isSelectDisabled: Bool

    private let label: GlassLabel = {
        let label = GlassLabel(style: .body2)
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.spacing = GlassSpacing.xSmall
        return stackView
    }()

    public var title: String {
        didSet {
            label.text = title
            updateAccessibility()
        }
    }

    /// Left icon image to set `leftIconImageView`
    public var leftIcon: GlassIcon? {
        didSet {
            guard let icon = leftIcon else { return }
            leftIconImageView.image = icon.imageSize16()
            updateUI()
        }
    }

    /// Right icon image to set `rightIconImageView`
    public var rightIcon: GlassIcon? {
        didSet {
            guard let icon = rightIcon else { return }
            rightIconImageView.image = icon.imageSize16()
            updateUI()
        }
    }

    /// Left aligned icon image view
    private var leftIconImageView = UIImageView()

    /// Right aligned icon image view
    private var rightIconImageView = UIImageView(image: GlassIcon.check.imageSize16())

    ///Only supported init method for GlassChip
    public init(title: String = "",
                isMultiSelect: Bool = false,
                isSelected: Bool = false,
                chipStyle: ChipStyle? = ChipStyle.medium,
                isSelectDisabled: Bool = false) {

        label.text = title
        self.title = title
        self.isMultiSelect = isMultiSelect
        self.isSelected = isSelected
        self.chipStyle = chipStyle!
        self.isSelectDisabled = isSelectDisabled
        self.longPressGestureRecognizer = UILongPressGestureRecognizer()
        super.init(frame: .zero)
        backgroundColor = GlassColor.gray00.uiColor
        self.longPressGestureRecognizer.addTarget(self, action: #selector(didPress))
        longPressGestureRecognizer.minimumPressDuration = 0
        addGestureRecognizer(longPressGestureRecognizer)
        postInit()
        updateUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    /// Responsible for animating the state change for the view
    private func updateUI() {
        updateAccessibility()
        UIView.animate(withDuration: GlassAnimation.animationTimeMedium, animations: { [weak self] in
            guard let self = self else { return }
            self.layer.borderWidth = self.isSelected ? self.selectedBorderWidth : self.unselectedBorderWidth
            self.layer.borderColor = self.isSelected
                ? self.selectedBorderColor.uiColor.cgColor
                : self.unselectedBorderColor.uiColor.cgColor
            self.layer.borderColor = self.isUserInteractionEnabled
                ? self.layer.borderColor : GlassColor.clear.uiColor.cgColor
            self.backgroundColor = self.isUserInteractionEnabled
                ? self.enabledBackgroundColor.uiColor
                : self.disabledBackgroundColor.uiColor
            self.label.textColor = self.isUserInteractionEnabled
                ? GlassColor.gray200.uiColor : GlassColor.gray50.uiColor
            self.label.font = self.isSelected
                ? GlassFont.subheading2().uiFont
                : GlassFont.body2().uiFont
            self.stackView.layoutIfNeeded()
        }, completion: nil)

        self.leftIconImageView.isHidden = self.leftIcon == .none
        if !self.isMultiSelect {
            self.rightIconImageView.isHidden = true
        } else {
            self.rightIconImageView.isHidden = self.isSelectDisabled ? false : !self.isSelected
        }
    }

    private func updateAccessibility() {
        var title = label.text ?? ""

        if !isSelectDisabled {
            if isSelected {
                title += " selected"
            } else {
                title += " not selected"
            }
        }
        if !isUserInteractionEnabled {
            title += " not enabled"
        }
        accessibilityLabel = title
    }
    /// Basic view layout function and adding to subview
    private func postInit() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(leftIconImageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(rightIconImageView)
        self.layer.borderColor = unselectedBorderColor.uiColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = unselectedBorderWidth
        self.accessibilityTraits = [.button]
        isAccessibilityElement = true
        label.isAccessibilityElement = false
        setConstraints()
    }

    @objc internal func didPress(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.layer.borderColor = GlassColor.gray60.uiColor.cgColor
            self.backgroundColor = GlassColor.gray20.uiColor
        case .changed:
            self.backgroundColor = GlassColor.gray20.uiColor
        default:
            isSelected = isSelectDisabled ? false : !isSelected
            hapticEngine.start(.selection)
            UIAccessibility.post(notification: .announcement, argument: self)
            tapAction?()
            self.backgroundColor = GlassColor.gray00.uiColor
        }
    }

    ///Setting up constraints for the layout of the view
    private func setConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var height = GlassSpacing.medium
        switch self.chipStyle {
        case .medium:
            height = GlassSpacing.medium
        case .large:
            height = GlassSpacing.medium + GlassSpacing.xSmall
        case .xLarge:
            height = GlassSpacing.medium + GlassSpacing.small
        }

        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        trailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlassSpacing.small)
        leadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlassSpacing.small)

        let constraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.xSmall),
            leadingConstraint!,
            trailingConstraint!,
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassSpacing.xSmall),
            heightAnchor.constraint(equalToConstant: height),
            rightIconImageView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            rightIconImageView.heightAnchor.constraint(equalToConstant: GlassSpacing.small),
            leftIconImageView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            leftIconImageView.heightAnchor.constraint(equalToConstant: GlassSpacing.small)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

#if DEBUG
extension GlassChip {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassChip

        fileprivate init(target: GlassChip) {
            self.target = target
        }

        var leftIconImageView: UIImageView { return target.leftIconImageView }
        var rightIconImageView: UIImageView { return target.rightIconImageView }
    }
}
#endif
