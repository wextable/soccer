//
//  GlassStepperView.swift
//  GlassUI
//
//  Created by Alex Johnson on 7/15/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

private let idleTimeout: TimeInterval = 4
private let idelTimeoutWhenVoiceOverIsOn: TimeInterval = 4 * idleTimeout

public class GlassStepperView: BaseView, GlassStepperLayoutRoot {
    public enum StepperStyle: CaseIterable {
        case small, large
    }

    public enum StepperType: CaseIterable {
        case primary, secondary

        /// This is for compatibility only. New code should use `secondary`
        public static let tertiary: StepperType = .secondary
    }

    /// A collection of steppers where only one stepper can be "active" (i.e. non-idle) at a time.
    public class ActivationGroup {
        public static let `default` = ActivationGroup()

        private var steppers: [Weak<GlassStepperView>] = []

        private struct Weak<Value: AnyObject> {
            weak var value: Value?
        }

        fileprivate func add(_ stepper: GlassStepperView) {
            remove(stepper)
            steppers.append(.init(value: stepper))

            if !stepper.isIdle {
                notify(sender: stepper)
            }
        }

        fileprivate func remove(_ stepper: GlassStepperView) {
            steppers = steppers.filter({ $0.value != nil && $0.value !== stepper })
        }

        fileprivate func notify(sender: GlassStepperView) {
            steppers.forEach {
                if let stepper = $0.value, stepper !== sender {
                    stepper.becomeIdle()
                }
            }
        }
    }

    public struct Model {
        public var value: Double
        public var isAtMin: Bool
        public var isAtMax: Bool
        public var hidesMinPrefix: Bool
        public var debounceDueTime: Int
        public var valueSuffix: String
        public var adjustableAccessibilityLabel: String
        public var accessibilityModel: AccessibilityModel
        public var addOnModel: AddOnModel?

        public init(value: Double = 0,
                    isAtMin: Bool = false,
                    isAtMax: Bool = false,
                    hidesMinPrefix: Bool = false,
                    debounceDueTime: Int = 0, // The time debounce should wait before triggering onChange event.
                    valueSuffix: String = "",
                    adjustableAccessibilityLabel: String = "",
                    accessibilityModel: AccessibilityModel = .init(),
                    addOnModel: AddOnModel? = nil) {
            self.value = value
            self.isAtMin = isAtMin
            self.isAtMax = isAtMax
            self.hidesMinPrefix = hidesMinPrefix
            self.debounceDueTime = debounceDueTime
            self.valueSuffix = valueSuffix
            self.adjustableAccessibilityLabel = adjustableAccessibilityLabel
            self.accessibilityModel = accessibilityModel
            self.addOnModel = addOnModel
        }
    }

    // MARK: - Public

    public var style: StepperStyle { inner.style }

    public var type: StepperType { inner.type }
    public let tracksIdle: Bool
    public var elevationLevel: LDElevationLevel {
        get { inner.elevationLevel }
        set { inner.elevationLevel = newValue }
    }

    public weak var activationGroup: ActivationGroup? {
        didSet {
            if oldValue !== activationGroup {
                oldValue?.remove(self)
                activationGroup?.add(self)
            }
        }
    }

    public let collapsesWhenIdle: Bool
    public let allowsDecrementAtMin: Bool
    public let allowsIncrementAtMax: Bool

    /// The text to show for the "add" button, when the stepper's value is `0`
    ///
    /// Note: If the add title is empty (`""`), the stepper will show the value `0` with +/- buttons.
    public var addTitle: String {
        didSet {
            if oldValue != addTitle {
                applyModel()
            }
        }
    }

    public let idleSuffix: String

    public var model: Model {
        didSet {
            applyModel()
        }
    }

    public var onIncrement: () -> Void = {}
    public var onDecrement: () -> Void = {}
    public var onLabelTap: () -> Void = {}

    /// Called on increment or on decrement
    /// onChange is triggered only after onIncrement and onDecrement
    ///  stop being called for debounceDueTime milliseconds.
    /// - Parameters:
    ///   - delta: the change (# of increments + # of decrements, decrements are negative).
    public var onChange: (_ delta: Int) -> Void = { _ in }

    /// The model used to set accessibilityLabel with product name and module context/information
    /// where `GlassStepperView.Model` gets initialized.
    ///
    /// # Example
    /// ```sh
    /// Add to cart Fuji apple, 1 in cart or Add to list iPad Pro 128gb, 1 in list
    /// Add to cart Fuji apple or Add to list iPad Pro 128gb
    /// ```
    public struct AccessibilityModel {
        public let title: String
        public let collapsed: String
        public let increment: String
        public let useSuffix: Bool
        public let useQuantityMenuTitle: Bool
        public let incrementButtonLabel: String
        public let decrementButtonLabel: String
        public let quantityMenuTitle: String

        public init(title: String = .init(),
                    collapsed: String = "in cart",
                    increment: String = "Add to cart",
                    useSuffix: Bool = true,
                    incrementButtonLabel: String = "increase quantity",
                    decrementButtonLabel: String = "decrease quantity",
                    useQuantityMenuTitle: Bool = false,
                    quantityMenuTitle: String = "double tap to open quantity menu") {
            self.title = title
            self.collapsed = collapsed
            self.increment = increment
            self.useSuffix = useSuffix
            self.incrementButtonLabel = incrementButtonLabel
            self.decrementButtonLabel = decrementButtonLabel
            self.useQuantityMenuTitle = useQuantityMenuTitle
            self.quantityMenuTitle = quantityMenuTitle
        }
    }

    /// The model used to set formatted strings context/information
    /// where `GlassStepperView.Model` gets initialized.
    ///
    /// # Example
    /// ```sh
    /// Height / Width / size in feet: 2′ 4″
    /// Weight 2lbs 3oz
    /// ```
    public struct AddOnModel {
        public var values: (first: Double, last: Double)
        public var valuesSuffix: (first: String, last: String)

        public init(values: (first: Double, last: Double) = (0, 0),
                    valuesSuffix: (first: String, last: String) = ("", "")) {
            self.values = values
            self.valuesSuffix = valuesSuffix
        }
    }

    // MARK: - Internal (for testing)

    enum AccessibilityState {
        case idle, focused, interacting
    }

    // MARK: - Private

    private let inner: GlassStepperInnerView

    private var isIdle: Bool = false {
        didSet {
            if oldValue != isIdle {
                applyModel()
            }
        }
    }

    private var idleTimer: Timer?
    public var disableIdleTimer: Bool = false {
        didSet {
            if disableIdleTimer {
                idleTimer?.invalidate()
            } else {
                becomeActive()
            }
        }
    }

    private var accessibilityState: AccessibilityState = .idle {
        didSet {
            if oldValue != accessibilityState {
                applyModel()
            }
        }
    }

    // MARK: - Core

    public init(style: StepperStyle = .small,
                type: StepperType = .primary,
                elevationLevel: LDElevationLevel = .zero,
                tracksIdle: Bool = false,
                activationGroup: ActivationGroup? = .default,
                collapsesWhenIdle: Bool = false,
                allowsDecrementAtMin: Bool = false,
                allowsIncrementAtMax: Bool = false,
                addTitle: String = "",
                idleSuffix: String = "",
                model: Model = Model()) {

        self.inner = GlassStepperInnerView(
            style: style,
            type: type,
            elevationLevel: elevationLevel
        )
        self.tracksIdle = tracksIdle
        self.activationGroup = activationGroup
        self.collapsesWhenIdle = collapsesWhenIdle
        self.allowsDecrementAtMin = allowsDecrementAtMin
        self.allowsIncrementAtMax = allowsIncrementAtMax
        self.addTitle = addTitle
        self.idleSuffix = idleSuffix
        self.model = model

        if tracksIdle {
            isIdle = true
        }

        super.init(frame: .zero)

        UIView.performWithoutAnimation {
            applyModel()
        }
    }

    public func setModel(_ newValue: Model, animated: Bool) {
        if animated {
            model = newValue
        } else {
            UIView.performWithoutAnimation {
                model = newValue
            }
        }
    }

    /// Prepares this view for reuse by clearing any internal state.
    public func prepareForReuse() {
        becomeIdle()
        inner.prepareForReuse()
    }

    private func applyModel() {
        inner.model = model.innerModel(isIdle: isIdle,
                                       accessibilityState: accessibilityState,
                                       collapsesWhenIdle: collapsesWhenIdle,
                                       allowsDecrementAtMin: allowsDecrementAtMin,
                                       allowsIncrementAtMax: allowsIncrementAtMax,
                                       addTitle: addTitle,
                                       idleSuffix: idleSuffix)
    }

    // MARK: - Actions

    private func mainAction() {
        if case .stepper = inner.model {
            if !isIdle {
                becomeActive()
                onLabelTap()
            }
            return
        }

        becomeActive()
        if model.isEmpty {
            inner.incrementDelta()
            onIncrement()
        }
    }

    private func incrementAction() {
        becomeActive()
        onIncrement()
    }

    private func decrementAction() {
        becomeActive()
        onDecrement()
    }

    private func changeAction(_ delta: Int) {
        onChange(delta)
    }

    // MARK: - Active/idle

    private func becomeActive() {
        guard tracksIdle else { return }

        isIdle = false
        idleTimer?.invalidate()
        let _idleTimeout = UIAccessibility.isVoiceOverRunning ? idelTimeoutWhenVoiceOverIsOn : idleTimeout
        idleTimer = Timer.scheduledTimer(timeInterval: _idleTimeout,
                                         target: self,
                                         selector: #selector(becomeIdle),
                                         userInfo: nil,
                                         repeats: false)

        activationGroup?.notify(sender: self)
    }

    @objc private func becomeIdle() {
        guard tracksIdle else { return }

        isIdle = true
        idleTimer?.invalidate()
        idleTimer = nil
    }

    // MARK: Extended hit region

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        inner.point(inside: inner.convert(point, from: self), with: event)
    }

    // MARK: View construction

    override public func constructView() {
        super.constructView()

        activationGroup?.add(self)

        inner.onMain = { [weak self] in self?.mainAction() }
        inner.onIncrement = { [weak self] in self?.incrementAction() }
        inner.onDecrement = { [weak self] in self?.decrementAction() }
        inner.onChange = { [weak self] delta in self?.changeAction(delta) }
    }

    override public func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        addAutoLayoutSubview(inner)
    }

    override public func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        inner.constraints(pinningTo: self).activate()
    }
}

#if DEBUG
extension GlassStepperView {
    public struct TestHooks {
        fileprivate let target: GlassStepperView

        var isIdle: Bool {
            target.isIdle
        }

        var accessibilityState: AccessibilityState {
            target.accessibilityState
        }

        var isIdleTimerRunning: Bool {
            target.idleTimer?.isValid ?? false
        }

        func fireIdleTimer() {
            target.idleTimer?.fire()
        }

        public func tapMainButton() {
            target.inner.testHooks.tapMainButton()
        }

        public func tapIncrementButton() {
            target.inner.testHooks.tapIncrementButton()
        }

        public func tapDecrementButton() {
            target.inner.testHooks.tapDecrementButton()
        }

        func mainButtonTitle(for state: UIControl.State) -> String? {
            target.inner.testHooks.mainButtonTitle(for: state)
        }
    }

    public var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
