//
//  GlassSnackbar.swift
//  GlassUI
//
//  Created by Bharath Rao on 4/20/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// Zeplin - https://zpl.io/VD0OL3r

public class GlassSnackbar: BaseView {

    public struct Model {
        /// The message to be displayed inside the snackbar.
        public var message: String
        /// The title of the action button.
        public var actionButtonTitle: String?
        /// Duration to show snackbar. Defaults to 3.5 seconds.
        public var duration: TimeInterval
        /// Whether the snackbar hides after performing its action. Defaults to false.
        public var hidesAfterPerformingAction: Bool
        /// A Boolean value indicating whether to announce view's content when Voice Over is ON. Defaults to true.
        public var needsAccessibilityAnnouncement: Bool

        public init(
            message: String,
            actionButtonTitle: String? = nil,
            duration: TimeInterval = 3.5,
            hidesAfterPerformingAction: Bool = false,
            needsAccessibilityAnnouncement: Bool = true
        ) {
            self.message = message
            self.actionButtonTitle = actionButtonTitle
            self.duration = duration
            self.hidesAfterPerformingAction = hidesAfterPerformingAction
            self.needsAccessibilityAnnouncement = needsAccessibilityAnnouncement
        }
    }

    public var model: Model {
        didSet { applyModel() }
    }

    /// The action to perform when the user taps the button
    public var action: (() -> Void)?

    /// Called when the snackbar dismisses and is removed from view
    public var onDismiss: (() -> Void)?

    // MARK: Private

    private let containerStackView = UIStackView(axis: .horizontal, alignment: .top)

    /// Label to display snackbar message
    private let label = GlassLabel(style: .body2)

    /// Button
    private let actionButton = GlassLinkButton(model: .init(
        normalColor: GlassColor.gray00.uiColor,
        highlightedColor: GlassColor.gray70.uiColor
    ))

    private struct Metrics {
        static let cornerRadius: CGFloat = 4.0
    }

    // An internal property to keep updated insets to adjust transformation for `ty`
    // while dismissing the animation
    private var newInsets: LayoutConstrainingInsets = .init()

    public init(model: Model, action: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.model = model
        self.action = action
        self.onDismiss = onDismiss

        super.init(frame: .zero)

        applyModel()
    }

    public convenience init(message: String) {
        self.init(model: .init(message: message))
    }

    public override func constructView() {
        super.constructView()

        layer.cornerRadius = Metrics.cornerRadius
        backgroundColor = GlassColor.gray160.uiColor

        containerStackView.spacing = GlassSpacing.mediumSmall

        label.textAlignment = .left
        label.numberOfLines = 3
        label.textColor = .white

        actionButton.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        actionButton.setBackgroundColor(GlassColor.gray160.uiColor, for: .highlighted)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(containerStackView)
        containerStackView.addArrangedSubview(label)
        containerStackView.addArrangedSubview(actionButton)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            containerStackView.constraints(pinningTo: self, insets: .init(GlassSpacing.small))
        )
    }

    private func applyModel() {
        label.text = model.message

        if let actionButtonTitle = model.actionButtonTitle {
            actionButton.setTitle(actionButtonTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    /// Presents the snackbar at the bottom of the given view.
    /// - Parameters:
    ///   - view: The view inside which the snackbar is displayed.
    ///   - insets: Insets to apply between `view` and the snackbar's leading, trailing, and bottom edges.
    public func showSnackbar(in view: UIView, insets: LayoutConstrainingInsets = 0) {
        showSnackbar(in: view) { snackbar in
            [snackbar.constraints(pinningTo: view, edges: [.horizontal, .bottom], insets: insets)]
        }
    }

    /// Presents the snackbar inside the given view with a custom layout.
    /// - Parameters:
    ///   - view: The view inside which the snackbar is displayed.
    ///   - constraints: A closure which returns an array of layout constraints defining the layout of the
    ///     snackbar within its superview.
    ///   - snackbar: A reference to the snackbar being laid out.
    public func showSnackbar(in view: UIView, constraints: (_ snackbar: GlassSnackbar) -> [LayoutConstraining]) {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addAutoLayoutSubview(self)

        NSLayoutConstraint.activate(constraints(self))

        // Show the animation to slide up on the presenting view
        let transition = CATransition()
        transition.type = .push
        transition.subtype = .fromTop
        transition.duration = GlassAnimation.animationTimeLong
        transition.timingFunction = .init(name: .easeInEaseOut)
        layer.add(transition, forKey: "slideIn.animation")

        DispatchQueue.main.asyncAfter(deadline: .now() + model.duration, execute: hideSnackbar)

        guard self.model.needsAccessibilityAnnouncement else { return }
        UIAccessibility.post(notification: .announcement, argument: self.model.message)
    }

    public func showSnackbar(
        in viewController: UIViewController,
        additionalInsets: LayoutConstrainingInsets = 0
    ) {
        guard let view = viewController.view else { return }

        let newInsets = getNewLayoutConstrainingInsets(for: viewController, with: additionalInsets)
        showSnackbar(in: view, insets: newInsets)
    }

    internal func hideSnackbar() {
        UIView.animate(
            withDuration: GlassAnimation.animationTimeLong,
            animations: {
                self.alpha = GlassAnimation.start.alpha
                self.transform.ty = self.bounds.height + self.newInsets.bottom
            },
            completion: { _ in
                self.removeFromSuperview()
                self.onDismiss?()
            }
        )
    }

    private func getNewLayoutConstrainingInsets(
        for viewController: UIViewController,
        with additionalInsets: LayoutConstrainingInsets) -> LayoutConstrainingInsets {

        newInsets = additionalInsets

        if let tabBarController = viewController.tabBarController, !tabBarController.tabBar.isHidden {
            newInsets.vertical.bottom += tabBarController.tabBar.frame.size.height
        } else {
            newInsets.vertical.bottom += viewController.view.safeAreaInsets.bottom
        }

        return newInsets
    }

    @objc private func performAction() {
        action?()

        if model.hidesAfterPerformingAction {
            hideSnackbar()
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassSnackbar {
    struct TestHooks {
        let target: GlassSnackbar

        func performAction() {
            target.performAction()
        }

        var newInsets: LayoutConstrainingInsets { target.newInsets }

        var label: GlassLabel { target.label }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
