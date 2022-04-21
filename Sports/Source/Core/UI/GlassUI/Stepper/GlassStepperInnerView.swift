//
//  GlassStepperInnerView.swift
//  GlassUI
//
//  Created by Alex Johnson on 7/17/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import class Combine.AnyCancellable
import class Combine.PassthroughSubject
import UIKit

public protocol GlassStepperLayoutRoot {}

private let animationDuration: TimeInterval = 0.3

/// CAUTION: This view inherits from `BaseControl` so that it can suppress touch events when inside table/collection
/// cells. It **does not** implement any of the actual `UIControl` behaviors, like control state or target/action.
class GlassStepperInnerView: ElevatingControl, GlassStepperLayoutRoot {
    typealias StepperStyle = GlassStepperView.StepperStyle

    typealias StepperType = GlassStepperView.StepperType

    enum Model: Equatable {
        case circlePlus(accessibilityLabel: String,
                        debounceDueTime: Int,
                        incrementButtonAccessibilityLabel: String,
                        decrementButtonAccessibilityLabel: String)
        case pill(label: String,
                  fitContent: Bool,
                  accessibilityLabel: String,
                  debounceDueTime: Int,
                  incrementButtonAccessibilityLabel: String,
                  decrementButtonAccessibilityLabel: String)
        case stepper(label: String,
                     shrinkLabelFont: Bool,
                     enableIncrement: Bool,
                     enableDecrement: Bool,
                     debounceDueTime: Int,
                     accessibilityLabel: String,
                     incrementButtonAccessibilityLabel: String,
                     decrementButtonAccessibilityLabel: String)
    }

    // MARK: Public

    let style: StepperStyle

    let type: StepperType

    var model: Model {
        didSet {
            if oldValue != model {
                applyModel(oldValue: oldValue)
            }
        }
    }

    var onMain: () -> Void = {}

    var onIncrement: () -> Void = { }

    var onDecrement: () -> Void = { }

    var onChange: (_ delta: Int) -> Void = { _ in }

    // MARK: Private

    private var expandedWidthConstraint: NSLayoutConstraint!

    private let mainButton: ExtendedHitRegionButton = {
        let mainButton = ExtendedHitRegionButton()
        mainButton.titleLabel?.adjustsFontSizeToFitWidth = false
        return mainButton
    }()

    private let incrementButton = ExtendedHitRegionButton()

    private var incrementButtonLeadingConstraint: NSLayoutConstraint!

    private var incrementButtonWidthConstraintWithTitle: NSLayoutConstraint!

    private var incrementButtonWidthConstraintWithoutTitle: NSLayoutConstraint!

    private let decrementButton = ExtendedHitRegionButton()

    private var fitContentContstraint: NSLayoutConstraint!

    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    // Used to implement debouncing
    enum DebounceType: Equatable {
        case enabled(dueTime: Int)  // milliseconds
        case disabled
    }

    private var currentDelta = 0
    private let subject = PassthroughSubject<Int, Never>()
    private var tasks: Set<AnyCancellable> = []

    /// The current state-transition animation. Changing the animation automatically cancels the current animation.
    private var animation: AnyCancellable?

    init(style: StepperStyle = .small,
         type: StepperType = .primary,
         elevationLevel: LDElevationLevel = .zero,
         model: Model = .circlePlus(accessibilityLabel: "",
                                    debounceDueTime: 0,
                                    incrementButtonAccessibilityLabel: "",
                                    decrementButtonAccessibilityLabel: "")) {
        self.style = style
        self.type = type
        self.model = model

        super.init(withAppearance: type.appearance, elevationLevel: elevationLevel)

        UIView.performWithoutAnimation {
            applyModel()
        }
    }

    func setModel(_ newValue: Model, animated: Bool) {
        if animated {
            model = newValue
        } else {
            UIView.performWithoutAnimation {
                model = newValue
            }
        }
    }

    /// Prepares this view for reuse by clearing any internal state.
    func prepareForReuse() {
        UIView.performWithoutAnimation {
            applyModel(oldValue: nil)
        }
    }

    /// Increment delta and update debounce
    func incrementDelta() {
        if case .enabled = model.debounceType {
            currentDelta += 1
            subject.send(currentDelta)
        }
    }

    /// Dcrement delta and update debounce
    func decrementDelta() {
        if case .enabled = model.debounceType {
            currentDelta -= 1
            subject.send(currentDelta)
        }
    }

    private func setupDebounce(type: DebounceType) {
        switch type {
        case .enabled(let dueTime):
            tasks.removeAll()
            subject
                .debounce(for: .milliseconds(dueTime), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.onChange(value)
                    self?.currentDelta = 0
                })
                .store(in: &tasks)
        case .disabled:
            break
        }
    }

    // MARK: - State transition

    private var animationLayoutRoot: UIView {
        let root = sequence(first: self, next: { $0.superview }).filter({ $0 is GlassStepperLayoutRoot }).last!
        return root.superview ?? root
    }

    private func applyModel(oldValue: Model? = nil) {
        let newValue = model

        mainButton.isUserInteractionEnabled = newValue.mainButtonUserInteractionEnabled

        if oldValue?.mainButtonTitle != newValue.mainButtonTitle ||
           oldValue?.mainButtonFont(for: style) !== newValue.mainButtonFont(for: style) {
            self.setButtonTitle(for: mainButton,
                                title: newValue.mainButtonTitle,
                                font: newValue.mainButtonFont(for: self.style))
        }

        if oldValue?.incrementButtonTitle != newValue.incrementButtonTitle && currentDelta == 0 {
            self.setButtonTitle(for: incrementButton,
                                title: newValue.incrementButtonTitle,
                                font: self.style.normalButtonFont)
            incrementButton.updateContentInsets(isCollapsed: !newValue.incrementButtonTitle.isEmpty)
        }

        var animator = Animator(layoutRoot: animationLayoutRoot)

        animator.updateHidden(of: mainButton, oldValue?.mainButtonHidden, newValue.mainButtonHidden)
        animator.updateHidden(of: incrementButton, oldValue?.incrementButtonHidden, newValue.incrementButtonHidden)
        animator.updateHidden(of: decrementButton, oldValue?.decrementButtonHidden, newValue.decrementButtonHidden)

        animator.updateActive(of: incrementButtonLeadingConstraint,
                              oldValue?.incrementButtonLeadingEdgeConstraintActive,
                              newValue.incrementButtonLeadingEdgeConstraintActive)

        animator.updateActive(of: incrementButtonWidthConstraintWithTitle,
                              oldValue?.incrementButtonWidthConstraintWithTitleActive,
                              newValue.incrementButtonWidthConstraintWithTitleActive)

        animator.updateActive(of: incrementButtonWidthConstraintWithoutTitle,
                              oldValue?.incrementButtonWidthConstraintWithoutTitleActive,
                              newValue.incrementButtonWidthConstraintWithoutTitleActive)

        animator.updateActive(of: expandedWidthConstraint,
                              oldValue?.expandedWidthConstraintActive,
                              newValue.expandedWidthConstraintActive)

        animator.updateActive(of: fitContentContstraint,
                              oldValue?.fitContentContstraintActive,
                              newValue.fitContentContstraintActive)

        animator.apply {
            self.incrementButton.isEnabled = newValue.incrementButtonEnabled
            self.setButtonImage(self.incrementButton, icon: .plus)
            self.decrementButton.isEnabled = newValue.decrementButtonEnabled
            self.setButtonImage(self.decrementButton, icon: .minus)
        }

        animator.updateConstant(of: fitContentContstraint, mainButton.titleLabel!.intrinsicContentSize.width)

        animation = animator.run(duration: animationDuration)

        setupAccessibility(with: newValue)

        guard let debounceType = oldValue?.debounceType else { return }
        if debounceType != newValue.debounceType {
            setupDebounce(type: newValue.debounceType)
        }
    }

    private func setButtonTitle(for button: ExtendedHitRegionButton, title: String, font: UIFont) {
        // Special case: If the text or font of the button is changing, animate it with a cross-fade
        // to avoid weird stretching:

        UIView.transition(
            with: mainButton,
            duration: animationDuration/3,
            options: .transitionCrossDissolve,
            animations: {
                button.setTitle(title, for: .normal)
                button.titleLabel!.font = font
            },
            completion: nil
        )
    }
    // MARK: - View construction

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2
        mainButton.layer.cornerRadius = mainButton.bounds.height / 2
        incrementButton.layer.cornerRadius = incrementButton.bounds.height / 2
        decrementButton.layer.cornerRadius = decrementButton.bounds.height / 2
    }

    override func constructView() {
        super.constructView()

        accessibilityElements = [mainButton, incrementButton, decrementButton]

        clipsToBounds = true

        constructButton(mainButton)
        constructButton(incrementButton)
        constructButton(decrementButton)

        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementButtonTapped), for: .touchUpInside)
    }

    private func constructButton(_ button: GlassButton) {
        button.setTitleColor(type.normalButtonText.uiColor, for: .normal)

        button.setTitleColor(type.highlightedButtonText.uiColor, for: .highlighted)
        button.setBackgroundColor(type.highlightedButtonBackground.uiColor, for: .highlighted)

        button.setTitleColor(type.disabledButtonText.uiColor, for: .disabled)

        button.contentEdgeInsets = .zero
        button.accessibilityTraits = .button
    }

    private func setButtonImage(_ button: UIButton, icon: GlassIcon) {
        let image = icon.image(model.buttonIconSize(for: style)).withRenderingMode(.alwaysOriginal)

        button.setImage(image.withTintColor(type.normalButtonText.uiColor), for: .normal)
        button.setImage(image.withTintColor(type.highlightedButtonText.uiColor), for: .highlighted)
        button.setImage(image.withTintColor(type.disabledButtonText.uiColor), for: .disabled)
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        addAutoLayoutSubview(mainButton)
        addAutoLayoutSubview(decrementButton)
        addAutoLayoutSubview(incrementButton)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        expandedWidthConstraint = widthAnchor.constraint(equalToConstant: style.expandedWidth)
        incrementButtonLeadingConstraint = incrementButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                                    constant: GlassSpacing.xxSmall)

        fitContentContstraint = incrementButton.centerXAnchor.constraint(equalTo: decrementButton.centerXAnchor)

        incrementButtonWidthConstraintWithoutTitle =
            incrementButton.widthAnchor.constraint(equalTo: incrementButton.heightAnchor)

        incrementButtonWidthConstraintWithTitle =
            incrementButton.widthAnchor.constraint(equalToConstant: 70)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: style.height),
            mainButton.constraints(pinningTo: self, insets: .uniform(GlassSpacing.xxSmall)),
            incrementButton.constraints(pinningTo: self,
                                        edges: [.trailing, .vertical],
                                        insets: .uniform(GlassSpacing.xxSmall)),
            decrementButton.constraints(pinningTo: self,
                                        edges: [.leading, .vertical],
                                        insets: .uniform(GlassSpacing.xxSmall)),
            decrementButton.widthAnchor.constraint(equalTo: decrementButton.heightAnchor)
        ])
    }

    // MARK: - UIKit Actions

    @objc private func mainButtonTapped() {
        onMain()
        feedbackGenerator.impactOccurred()
    }

    @objc private func incrementButtonTapped() {
        incrementDelta()
        onIncrement()
        feedbackGenerator.impactOccurred()
    }

    @objc private func decrementButtonTapped() {
        decrementDelta()
        onDecrement()
        feedbackGenerator.impactOccurred()
    }

    private func setupAccessibility(with model: Model) {
        mainButton.accessibilityIdentifier = "stepper.mainButton"
        incrementButton.accessibilityIdentifier = "stepper.incrementButton"
        decrementButton.accessibilityIdentifier = "stepper.decrementButton"

        incrementButton.accessibilityHint = model.incrementButtonAccessibilityHint
        decrementButton.accessibilityHint = model.decrementButtonAccessibilityHint

        mainButton.accessibilityTraits = model.accessibilityTraits
        mainButton.accessibilityLabel = model.accessibilityLabel
        incrementButton.accessibilityLabel = !model.incrementButtonTitle.isEmpty ? model.accessibilityLabel : ""
    }
}

// MARK: - Extended hit region

private let hitTolerance: CGFloat = 8

private extension CGPoint {
    func bucketed(in bounds: CGRect, tolerance: CGFloat) -> CGPoint {
        var point = self

        if (bounds.minX - tolerance ..< bounds.minX) ~= point.x {
            point.x = bounds.minX
        } else if (bounds.maxX ..< bounds.maxX + tolerance) ~= point.x {
            point.x = bounds.maxX.nextDown
        }

        if (bounds.minY - tolerance ..< bounds.minY) ~= point.y {
            point.y = bounds.minY
        } else if (bounds.maxY ..< bounds.maxY + tolerance) ~= point.y {
            point.y = bounds.maxY.nextDown
        }

        return point
    }
}

extension GlassStepperInnerView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point.bucketed(in: bounds, tolerance: hitTolerance), with: event)
    }
}

private class ExtendedHitRegionButton: GlassButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point.bucketed(in: bounds, tolerance: hitTolerance), with: event)
    }

    func updateContentInsets(isCollapsed: Bool) {
            self.contentEdgeInsets = UIEdgeInsets( top: 0,
                                                   left: 0,
                                                   bottom: 0,
                                                   right: isCollapsed ? GlassSpacing.small : 0)
            self.titleEdgeInsets = UIEdgeInsets( top: 0,
                                                 left: isCollapsed ? GlassSpacing.xSmall : 0,
                                                 bottom: 0,
                                                 right: 0 )
        }
}

#if DEBUG
extension GlassStepperInnerView {
    struct TestHooks {
        private let target: GlassStepperInnerView

        fileprivate init(target: GlassStepperInnerView) {
            self.target = target
        }

        private func simulateTap(on control: UIControl) {
            guard let control = control.hitTest(target.mainButton.bounds.origin, with: nil) as? UIControl else {
                return
            }

            control.sendActions(for: .touchDown)
            control.sendActions(for: .touchUpInside)
        }

        func tapMainButton() {
            simulateTap(on: target.mainButton)
        }

        func tapIncrementButton() {
            simulateTap(on: target.incrementButton)
        }

        func tapDecrementButton() {
            simulateTap(on: target.decrementButton)
        }

        func mainButtonTitle(for state: UIControl.State) -> String? {
            target.mainButton.title(for: state)
        }

        var mainButtonAccessibilityTraits: UIAccessibilityTraits {
            target.mainButton.accessibilityTraits
        }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
