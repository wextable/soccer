//
//  PopoverContainerViewController.swift
//  GlassUI
//
//  Created by Amisha Chordia on 12/08/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

extension PopoverContainerViewController: KeyboardObserver {
    func keyboardWillShow(_ notification: Notification) {
        guard popover.tiersType == .oneTierAutomatic,
              popover.isKeyboardObserver,
              let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              !isKeyboardShowing
        else { return }

        isKeyboardShowing = true
        let currentKeyboardHeight = rect.height
        let orientationMaxHeight = isLandscape ? PopoverLayout.landscapeHeight : PopoverLayout.portraitHeight
        popoverAutoHeightConstraint?.constant = orientationMaxHeight - currentKeyboardHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func keyboardDidShow(_ notification: Notification) { }
    func keyboardWillHide(_ notification: Notification) {
        guard popover.tiersType == .oneTierAutomatic,
              popover.isKeyboardObserver
        else { return }

        isKeyboardShowing = false
        popoverAutoHeightConstraint?.constant = PopoverLayout.landscapeHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

/// Main class to show Popovers with BottomSheet content on iPads
final class PopoverContainerViewController: BaseViewController {
    public static let popoverBottomAlignmentConstant: CGFloat = GlassSpacing.mediumLarge

    private struct PopoverLayout {
        static let fixedWidth: CGFloat = 504
        static var automaticHeight: CGFloat = 504
        static var landscapeHeight: CGFloat = 0
        static var portraitHeight: CGFloat = 0

        static func setUpPopoverDefaultHeights() {
            let screenBounds = UIScreen.main.bounds
            if !UIScreen.main.isLandscape() {
                // Portrait
                PopoverLayout.portraitHeight = screenBounds.height * 0.9
                PopoverLayout.landscapeHeight = screenBounds.width * 0.9
            } else {
                // Landcsape
                PopoverLayout.portraitHeight = screenBounds.width * 0.9
                PopoverLayout.landscapeHeight = screenBounds.height * 0.9
            }
        }
    }

    private enum Constants {
        static let maxDimViewAlpha: CGFloat = 0.65
        static let dimmingViewAnimationDuration: TimeInterval = 0.3
    }

    private var isKeyboardShowing: Bool = false
    private let popover: BottomSheetable
    private let dimmingView = UIView()
    private let popoverAlignment: PopoverAlignment
    private var popoverAutoHeightConstraint: NSLayoutConstraint?
    private var popoverHeightConstraint: NSLayoutConstraint?
    private var isLandscape: Bool {
        UIScreen.main.isLandscape()
    }

    init(bottomSheet: BottomSheetable, alignment: PopoverAlignment) {
        self.popover = bottomSheet
        self.popoverAlignment = alignment
        super.init(nibName: nil, bundle: nil)

        PopoverLayout.setUpPopoverDefaultHeights()
        setupPopoverViewController()
        setupPopover()
        setupDimmingView()
    }

    private func setupDimmingView() {
        dimmingView.backgroundColor = GlassColor.black.uiColor
        dimmingView.alpha = 0
    }

    private func setupPopoverViewController() {
        addChild(popover)
        view.addAutoLayoutSubview(popover.view)

        NSLayoutConstraint.activate(popover.view.constraints(pinningTo: view, edges: [.leading, .trailing, .top]))

        popoverAutoHeightConstraint = popover.view.heightAnchor
            .constraint(lessThanOrEqualToConstant: PopoverLayout.landscapeHeight)
        popoverHeightConstraint = popover.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        updateConstraint()

        popover.didMove(toParent: self)
        popover.bottomSheetableActionDelegate = self
        view.backgroundColor = GlassColor.white.uiColor
    }

    private func updateConstraint() {
        switch popover.tiersType {
        case .oneTierAutomatic:
            PopoverLayout.automaticHeight = popover.maxBottomSheetHeight
            popoverAutoHeightConstraint?.activate()
            popoverHeightConstraint?.deactivate()
        default:
            popoverHeightConstraint?.activate()
            popoverAutoHeightConstraint?.deactivate()
        }
    }

    private func setupPopover() {
        popover.view.accessibilityIdentifier = "bottomsheet popover"
        setPopoverPreferredContentSize()
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.permittedArrowDirections = []
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if popover.isKeyboardObserver {
            setupKeyboardObserver()
        }

        if let presentingVC = presentingViewController {
            presentingVC.view.addAutoLayoutSubview(dimmingView)
            NSLayoutConstraint.activate(presentingVC.view.constraints(pinningTo: dimmingView))
        }
        dimmingView.alpha = 0
        UIView.animate(withDuration: animated ? Constants.dimmingViewAnimationDuration : 0) {
            self.dimmingView.alpha = Constants.maxDimViewAlpha
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if popover.isKeyboardObserver {
            destroyKeyboardObservers()
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        dimmingView.removeFromSuperview()
        super.viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeightForOneTierAutomaticBottomSheet()
    }

    private func updateHeightForOneTierAutomaticBottomSheet() {
        guard popover.tiersType == .oneTierAutomatic else {
            return
        }
        let oneTierAutoPopoverHeight = popover.contentView.frame.height
        guard PopoverLayout.automaticHeight != oneTierAutoPopoverHeight else {
            return
        }

        PopoverLayout.automaticHeight = oneTierAutoPopoverHeight
        setPopoverPreferredContentSize()
    }
}

extension PopoverContainerViewController {
    private func setPopoverPreferredContentSize() {
        switch popover.tiersType {
        case .oneHeight(let height):
            if popover.maxBottomSheetHeight != height {
                preferredContentSize = CGSize(width: PopoverLayout.fixedWidth,
                                              height: height)
            } else {
                preferredContentSize = CGSize(width: PopoverLayout.fixedWidth,
                                              height: isLandscape ?
                                                PopoverLayout.landscapeHeight
                                                : PopoverLayout.portraitHeight)
            }
        case .oneTierAutomatic:
            preferredContentSize = CGSize(width: PopoverLayout.fixedWidth,
                                          height: PopoverLayout.automaticHeight)
        default:
            preferredContentSize = CGSize(width: PopoverLayout.fixedWidth,
                                          height: isLandscape ?
                                            PopoverLayout.landscapeHeight
                                            : PopoverLayout.portraitHeight)
        }
    }
}

extension PopoverContainerViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController,
                                       willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>,
                                       in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        switch popoverAlignment {
        case .center:
            rect.pointee = CGRect(origin: .init(x: view.pointee.frame.width/2,
                                                y: view.pointee.frame.height/2),
                                  size: .zero)
        case .bottomCenter:
            rect.pointee = CGRect(origin: .init(x: view.pointee.frame.width/2,
                                                y: view.pointee.frame.height - Self.popoverBottomAlignmentConstant),
                                  size: .zero)
        }
        setPopoverPreferredContentSize()
    }
}

extension PopoverContainerViewController: BottomSheetableActionDelegate {
    func triggerDismiss(_ sender: BottomSheetable) {
        popover.shouldDismiss { [weak self] allowed in
            guard let self = self else { return }
            // Dismiss if allowed
            if allowed {
                self.view.endEditing(true)
                self.dismiss(animated: true) {
                    self.popover.dismissCompletion()
                }
            }
        }
    }

    func triggerViewUpdate(_ sender: BottomSheetable) {
        setPopoverPreferredContentSize()
        updateConstraint()
    }

    func updateTier(_ sender: BottomSheetable, change: BottomSheetChange) -> BottomSheetTier {
        sender.startingTier
    }

    func triggerPopoverRectUpdate() {
        updateHeightForOneTierAutomaticBottomSheet()
    }
}

#if DEBUG
extension PopoverContainerViewController {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: PopoverContainerViewController

        fileprivate init(target: PopoverContainerViewController) {
            self.target = target
        }

        var popOverFixedWidth: CGFloat {
            PopoverLayout.fixedWidth
        }

        var dimmingView: UIView {
            target.dimmingView
        }

        var popoverAlignment: PopoverAlignment {
            target.popoverAlignment
        }

        var isKeyboardShowing: Bool {
            target.isKeyboardShowing
        }

        var popoverHeightConstraint: NSLayoutConstraint? {
            target.popoverHeightConstraint
        }

        var popoverAutoHeightConstraint: NSLayoutConstraint? {
            target.popoverAutoHeightConstraint
        }
    }
}
#endif
