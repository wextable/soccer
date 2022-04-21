//
//  GlassSnackbarStackView.swift
//  GlassUI
//
//  Created by James Ajhar on 11/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// `GlassSnackbarStackView` is a way to show multiple snackbars at once
///
/// It acts as a container class for `GlassSnackBar`
public class GlassSnackbarStackView: UIStackView, Accessible {

    public enum PresentationMode {
        /// Specifies to present Snackbars within.
        case inView(UIView)
        /// Specifies that snackbars should be presented in a separate window above all content.
        case alwaysOnTop
    }

    /// A running list of visible snackbars
    private var snackbarViews = [GlassSnackbar]()

    /// Max number of snackbars visible
    public var limit: Int = 2 {
        didSet {
            removeOldestSnackbarIfNeeded()
        }
    }

    /// Public facing getter for visible snackbar views
    public var visibleSnackbars: [GlassSnackbar] {
        return snackbarViews
    }

    private var snackbarWindow: SnackbarWindow?

    /// Initializer
    /// - Parameters:
    ///   - limit: The max number of snackbars that can display on screen
    ///   - spacing: The vertical spacing between snackbar views
    public init(limit: Int = 2, spacing: CGFloat = 0) {
        super.init(frame: .zero)

        self.limit = limit
        self.axis = .vertical
        self.distribution = .fillEqually
        self.spacing = spacing
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Call to display the snackbar stack within a parent view controller
    /// - Parameters:
    ///   - mode: Specifies how the snackbar should be presented with respect to other content.
    ///   - insets: The vertical and horizontal insets to offset the snackbar view when displaying
    public func showSnackbarStack(mode: PresentationMode,
                                  insets: LayoutConstrainingInsets = .init(vertical: GlassSpacing.small,
                                                                           horizontal: GlassSpacing.small)) {
        guard superview == nil else {
            assertionFailure("GlassSnackbarStackView.showSnackbarStack() has already been called.")
            return
        }

        let showOnView: UIView
        switch mode {
        case .inView(let view):
            showOnView = view

        case .alwaysOnTop:
            let snackbarWindow = SnackbarWindow()
            let snackbarViewController = SnackbarViewController()
            snackbarWindow.rootViewController = snackbarViewController
            snackbarWindow.windowLevel = UIWindow.Level.alert
            snackbarWindow.backgroundColor = UIColor.clear

            self.snackbarWindow = snackbarWindow
            showOnView = snackbarViewController.view
        }

        showOnView.addAutoLayoutSubview(self)
        let constraints = [self.constraints(pinningTo: showOnView, edges: [.horizontal, .bottom], insets: insets)]
        NSLayoutConstraint.activate(constraints)
        showOnView.layoutIfNeeded()
    }

    /// This is a convenience method to show snackbar
    ///
    /// [Zeplin](https://zpl.io/VD0OL3r)
    ///
    /// # Example
    /// ```swift
    /// let vc = viewController()
    /// vc.showSnackbarView(model: .init(message: "message"))
    /// ```
    ///
    /// - Parameters:
    ///     - model: The configuration model for the snackbar.
    ///     - additionalInsets: Used for positioning the snackbar. Default is 16 horizontal, 8 vertical as per zeplin
    ///     - action: The action to perform when the user taps the action button on the snackbar.
    ///     - animated: True if the snackbar should animate in
    @discardableResult
    public func insertSnackbarView(
        model: GlassSnackbar.Model,
        additionalInsets: LayoutConstrainingInsets = .init(
            vertical: GlassSpacing.xSmall,
            horizontal: GlassSpacing.small
        ),
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        animated: Bool = true
    ) -> GlassSnackbar {
        let snackbar = GlassSnackbar(model: model, action: action, onDismiss: onDismiss)
        showSnackbar(snackbar, animated: animated)
        removeOldestSnackbarIfNeeded()
        return snackbar
    }

    private func showSnackbar(_ snackbar: GlassSnackbar, animated: Bool = true) {
        snackbarWindow?.makeKeyAndVisible()

        snackbarViews.append(snackbar)
        addArrangedSubview(snackbar)

        if animated {
            // Animate the snackbar into the stack by sliding up
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromTop
            transition.duration = GlassAnimation.animationTimeLong
            transition.timingFunction = .init(name: .easeInEaseOut)
            snackbar.layer.add(transition, forKey: "slideIn.animation")

            UIView.animate(withDuration: GlassAnimation.animationTimeShort) {
                // Resize the stackview
                self.layoutIfNeeded()
            }
        }

        // Hide snackbar after x duration
        DispatchQueue.main.asyncAfter(deadline: .now() + snackbar.model.duration) { [weak self] in
            snackbar.hideSnackbar()
            self?.snackbarViews.removeAll(where: { $0 == snackbar })

            if self?.snackbarViews.isEmpty == true {
                self?.snackbarWindow?.resignKey()
                self?.snackbarWindow?.isHidden = true
            }
        }

        guard snackbar.model.needsAccessibilityAnnouncement else { return }
        UIAccessibility.post(notification: .announcement, argument: snackbar.model.message)
    }

    private func removeOldestSnackbarIfNeeded() {
        while snackbarViews.count > limit {
            let snackbar = snackbarViews.first
            snackbar?.hideSnackbar()
            snackbarViews.removeFirst()
        }
    }
}

class SnackbarWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        let viewController = hitView.next as? SnackbarViewController
        if hitView.isKind(of: SnackbarWindow.self) || viewController != nil {
            return nil
        }
        return hitView
    }
}

private class SnackbarViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassSnackbarStackView {
    struct TestHooks {
        let target: GlassSnackbarStackView

        var snackbarWindow: SnackbarWindow? { target.snackbarWindow }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
