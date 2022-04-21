//
//  GlassRadioButtonGroup.swift
//  GlassUI
//
//  Created by John Liedtke on 4/28/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A vertical control used to select a single value from a group of values.
///
/// The control mimics the material design radio button group and should be used sparingly users are not accustom to
/// this detested control in iOS.
///
/// To use the control, provide an array of `GlassRadioButtonGroup.Item`s and monitor for selection using `onSelection`.
///
/// # Zeplin
/// Found [here](https://zpl.io/aB0Z0QL).
///
/// - Author: John Liedtke
public final class GlassRadioButtonGroup<T>: BaseView where T: Equatable {

    /// A type representing an item in a `GlassRadioButtonGroup`.
    public class Item {

        /// The title of the item that appears adjacent to the radio circle.
        public let title: String

        /// The sub title of the item that appears below the title.
        public let subtitle: String?

        /// The actual value of the item.
        public let value: T

        fileprivate let stackView: UIStackView = .init(axis: .vertical)
        fileprivate let button: RadioButton
        fileprivate let subtitleView: UIStackView = .init(axis: .horizontal)
        fileprivate let subtitleLabel: GlassLabel = {
            let label = GlassLabel(style: .body2)
            label.numberOfLines = 0
            label.textColor = GlassColor.gray100.uiColor
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            return label
        }()

        public init(title: String, subtitle: String? = nil, value: T) {
            self.title = title
            self.subtitle = subtitle
            self.value = value
            var accessibilityText = title
            if let inSubtitle = subtitle {
                accessibilityText += ", " + inSubtitle
            }
            self.button = RadioButton(title: title, accessibilityLabelText: accessibilityText)
            self.button.setContentCompressionResistancePriority(.required, for: .horizontal)
            self.subtitleView.isHidden = subtitle == nil
            self.subtitleLabel.text = subtitle
            subtitleLabel.isAccessibilityElement = false

            let spacer = UIView(frame: .zero)
            spacer.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
            subtitleView.addArrangedSubview(spacer)
            subtitleView.addArrangedSubview(subtitleLabel)
            stackView.addArrangedSubview(subtitleView)
            NSLayoutConstraint.activate(
                spacer.widthAnchor.constraint(equalTo: button.circleView.widthAnchor,
                                              constant: GlassSpacing.xSmall + GlassSpacing.xxSmall)
            )
        }
    }

    /// A handler for observing user selection of an item.
    public var onSelection: ((Item) -> Void)?

    /// The text of the label that appears above the radio button group.
    public var labelText: String? {
        get { label.text }
        set { label.text = newValue }
    }

    /// A Boolean value indicating whether the radio button group is enabled.
    public var isEnabled = true {
        didSet { items.forEach({ $0.button.isEnabled = isEnabled }) }
    }

    /// The currently selected item in the group.
    public var selectedItem: Item? {
        get { items.first(where: { $0.button.isSelected }) }
        set { selectItem(newValue) }
    }

    /// The currently selected value in the group.
    public var selectedValue: T? {
        get { selectedItem?.value }
        set { selectedItem = items.first { $0.value == newValue } }
    }

    /// The items that appear in the radio group.
    public var items: [Item] = [] {
        didSet { clearAndSetUpItems() }
    }

    private let label = GlassLabel(style: .body2)
    private let buttonStackView = UIStackView(axis: .vertical)
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// Creates and returns a button group with the provided `items`.
    public init(items: [Item] = []) {
        super.init(frame: .zero)
        self.items = items
        clearAndSetUpItems()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(label)
        addAutoLayoutSubview(buttonStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        buttonStackView.spacing = GlassSpacing.small + GlassSpacing.xxSmall
        NSLayoutConstraint.activate(
            label.constraints(pinningTo: self, edges: [.leading, .top, .trailing]),
            buttonStackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: GlassSpacing.small),
            buttonStackView.constraints(pinningTo: self, edges: [.leading, .trailing, .bottom])
        )
    }

    private func clearAndSetUpItems() {
        buttonStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        items.forEach {
            $0.button.addTarget(self, action: #selector(didTapRadioButton(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview($0.stackView)
        }
    }

    @objc private func didTapRadioButton(_ button: RadioButton) {
        selectItem(items.first(where: { $0.button === button }), userTap: true)
    }

    private func selectItem(_ item: Item?, userTap: Bool = false) {
        guard item?.value != selectedItem?.value else { return }

        items.forEach { $0.button.isSelected = false }

        let selectedItemButton = items.first(where: { $0.value == item?.value })
        selectedItemButton?.button.isSelected = true

        if userTap, let item = item {
            onSelection?(item)
            feedbackGenerator.impactOccurred()
        }
    }
}

// MARK: - RadioButton

private class RadioButton: UIButton {

    override var intrinsicContentSize: CGSize {
        guard let titleLabel = titleLabel else { return .zero }

        let size = titleLabel.intrinsicContentSize
        return CGSize(
            width: size.width + contentEdgeInsets.left + contentEdgeInsets.right,
            height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom
        )
    }

    private let circle = CircleView()

    var circleView: UIView {
        circle
    }

    private lazy var hapticEngine: GlassHapticEngine = {
        let engine = GlassHapticEngine()
        engine.view = circle
        return engine
    }()

    override var isSelected: Bool {
        didSet {
            applyIsSelected()
        }
    }

    override var isEnabled: Bool {
        didSet { circle.isEnabled = isEnabled }
    }

    override var isHighlighted: Bool {
        didSet { circle.isHighlighted = isHighlighted }
    }

    override func sendActions(for controlEvents: UIControl.Event) {
        if controlEvents == .touchUpInside {
            if !isSelected {
                hapticEngine.start(.medium)
            }
            super.sendActions(for: controlEvents)
        }
    }

    init(title: String, accessibilityLabelText: String) {
        super.init(frame: .zero)

        contentHorizontalAlignment = .leading
        contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
        titleLabel?.font = GlassFont.body2().uiFont
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        setTitle(title, for: .normal)
        setTitleColor(GlassColor.gray140.uiColor, for: [.normal, .selected])
        setTitleColor(GlassColor.gray140.uiColor, for: .normal)
        setTitleColor(GlassColor.gray50.uiColor, for: [.disabled, .selected])
        setTitleColor(GlassColor.gray50.uiColor, for: .disabled)

        circle.translatesAutoresizingMaskIntoConstraints = true
        addSubview(circle)

        self.accessibilityLabel = accessibilityLabelText
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let titleLabel = titleLabel, let font = titleLabel.font else {
            return
        }

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width

        let y = titleLabel.frame.origin.y
        circle.frame = CGRect(origin: .init(x: 0, y: y), size: .init(font.lineHeight)).integral

        let spacing: CGFloat = circle.bounds.width + GlassSpacing.xSmall + GlassSpacing.xxSmall
        contentEdgeInsets = .init(top: GlassSpacing.xxSmall, left: spacing, bottom: GlassSpacing.xxSmall, right: 0)
    }

    private func applyIsSelected() {
        layer.removeAllAnimations()
        UIView.transition(with: titleLabel!, duration: 0.15, options: [.transitionCrossDissolve], animations: {
            self.titleLabel?.font = self.isSelected ? GlassFont.subheading2().uiFont : GlassFont.body2().uiFont
        })
        UIView.animate(withDuration: 0.15) { self.circle.isSelected = self.isSelected }
    }
}

// MARK: - RadioButton.CircleView

extension RadioButton {

    private class CircleView: BaseView {

        var isSelected = false {
            didSet { applyState() }
        }

        var isHighlighted = false {
            didSet { applyState() }
        }

        var isEnabled: Bool = true {
            didSet { applyState() }
        }

        private let outerCircle = Circle()
        private let innerCircle = Circle()

        init() {
            super.init(frame: .zero)
            applyState()
        }

        override func constructView() {
            super.constructView()

            isUserInteractionEnabled = false
        }

        override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()

            addAutoLayoutSubview(outerCircle)
            addAutoLayoutSubview(innerCircle)
        }

        override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            NSLayoutConstraint.activate(
                outerCircle.constraints(pinningTo: self),

                innerCircle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.60),
                innerCircle.heightAnchor.constraint(equalTo: innerCircle.widthAnchor),
                innerCircle.constraints(centeringInside: self),

                widthAnchor.constraint(equalTo: heightAnchor)
            )
        }

        private func applyState() {
            innerCircle.transform = isSelected ? .identity : .init(scaleX: 0.001, y: 0.001)
            outerCircle.layer.borderWidth = isHighlighted ? 2.0 : 1.0
            let circleColor: UIColor = isEnabled ? .black : GlassColor.gray50.uiColor
            outerCircle.layer.borderColor = circleColor.cgColor
            innerCircle.backgroundColor = circleColor
        }

        // swiftlint:disable:next nesting
        private class Circle: UIView {
            override func layoutSubviews() {
                super.layoutSubviews()
                layer.cornerRadius = bounds.size.width / 2.0
                layer.masksToBounds = true
            }
        }
    }
}

#if DEBUG
public extension GlassRadioButtonGroup {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassRadioButtonGroup

        fileprivate init(target: GlassRadioButtonGroup) {
            self.target = target
        }

        public func radioAccessibilityLabel(at index: Int) -> String? {
            guard index < self.target.buttonStackView.arrangedSubviews.count else {
                return nil
            }
            let itemStackView = self.target.buttonStackView.arrangedSubviews[index] as? UIStackView
            return itemStackView?.arrangedSubviews[0].accessibilityLabel
        }
    }
}
#endif

#if DEBUG
public extension GlassRadioButtonGroup.Item {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }
    struct TestHooks {
        private var target: GlassRadioButtonGroup.Item

        fileprivate init(target: GlassRadioButtonGroup.Item) {
            self.target = target
        }

        public var containerStackView: UIStackView {
            return self.target.stackView
        }
    }
}
#endif
