//
//  BottomSheetNavigationController.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/11/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A container view controller that adopts the BottomSheetable Protocol and defines a stack-based scheme
/// for navigating hierarchical content for View Controllers that also adopt the BottomSheetable Protocol
///
/// The root `BottomSheetable` View Controller sets the intital values for laying out the bottomSheet view.
/// Additional ViewControllers that adopt `BottomSheetable` replace the current bottomSheet parameters
/// as controllers are pushed and removed from the stack it is not advised to use controllers with varing
/// content heights as it can result in unexpected effects.
///
/// ```swift
/// let rootViewController = BottomSheetableViewController()
/// let nav = BottomSheetNavigationController(rootBottomSheet: rootViewController)
/// presentingViewController.present(bottomSheet: nav, as: .modal)
/// ```
///
/// Do **not** present NavigationController as a `.child`.  This presentation style is still experimental for
/// presenting a navigation container as a subview and may have unexpected effects
///
public class BottomSheetNavigationController: GlassNavigationController {
    private var currentBottomSheet: BottomSheetable {
        didSet {
            handleSheetUpdate()
        }
    }

    private var currentBottomSheetLayout: Layout?
    private var didViewPushedToStack = false

    var dynamicPopoverHeight: CGFloat? {
        didSet {
            currentBottomSheet.bottomSheetableActionDelegate?.triggerPopoverRectUpdate()
        }
    }

    public init(rootBottomSheet: BottomSheetable) {
        self.currentBottomSheet = rootBottomSheet
        rootBottomSheet.edgesForExtendedLayout = []

        super.init(rootViewController: rootBottomSheet)
        delegate = self

        setupAppearance()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // next run loop
        DispatchQueue.main.async {
            self.handleSheetUpdate()
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dynamicPopoverHeight = currentBottomSheet.contentView.frame.height
    }

    private func setupAppearance() {
        let backButtonImage = GlassIcon.chevronLeft.imageSize24()
        let navigationBarAppearence = UINavigationBarAppearance()
        navigationBarAppearence.shadowColor = nil
        navigationBarAppearence.backgroundColor = currentBottomSheet.backgroundColor
        navigationBarAppearence.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        navigationBar.isTranslucent = true
        navigationBarAppearence.titleTextAttributes = [NSAttributedString.Key.font: GlassFont.heading().uiFont]

        navigationBar.standardAppearance = navigationBarAppearence
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        navigationBar.tintColor = .black
    }

    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        didViewPushedToStack = true
        viewController.edgesForExtendedLayout = []
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                          style: .plain,
                                                                          target: nil,
                                                                          action: nil)
        if super.topViewController != viewController {
            super.pushViewController(viewController, animated: animated)
            update(viewController: viewController)
        }
    }

    override public func popViewController(animated: Bool) -> UIViewController? {
        let previousIndex = viewControllers.count - 2
        if previousIndex >= 0 {
            let previousVC = viewControllers[previousIndex]
            update(viewController: previousVC)
        }
        return super.popViewController(animated: animated)
    }

    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let rootVC = viewControllers.first {
            update(viewController: rootVC)
        }
        return super.popToRootViewController(animated: animated)
    }

    override public func popToViewController(_ viewController: UIViewController,
                                             animated: Bool) -> [UIViewController]? {
        if let viewController = viewControllers.first(where: { $0 == viewController }) {
            update(viewController: viewController)
        }

        return super.popToViewController(viewController, animated: animated)
    }

    private func update(viewController: UIViewController) {
        if let bottomSheet = viewController as? BottomSheetable {
            currentBottomSheet = bottomSheet
            currentBottomSheet.bottomSheetableActionDelegate = bottomSheetableActionDelegate
            currentBottomSheet.bottomSheetableActionDelegate?.triggerViewUpdate(currentBottomSheet)
        }
    }

    public var maxBottomSheetHeight: CGFloat {
        currentBottomSheet.maxBottomSheetHeight
    }

    // do not override this value, it is set for you
    weak public var bottomSheetableActionDelegate: BottomSheetableActionDelegate? {
        didSet { currentBottomSheet.bottomSheetableActionDelegate = bottomSheetableActionDelegate }
    }

    private func handleSheetUpdate() {
        guard currentBottomSheet.tiersType == .oneTierAutomatic,
            let bottomSheetSuperview = currentBottomSheet.contentView.superview else { return }

        currentBottomSheetLayout = nil

        // Some more investigation should be done that won't require using a constant like this.
        // The traditional ways of going under a nav bar do not work due to the navigation controller being
        // containerized (.edgesForExtendedLayout = [])
        let navigationBarHeight = navigationBar.frame.height
        let constraintInset = LayoutConstrainingInsets(top: navigationBarHeight, horizontal: 0, bottom: 0)

        currentBottomSheet.contentView.translatesAutoresizingMaskIntoConstraints = false
        currentBottomSheetLayout = .init([
            currentBottomSheet.contentView.constraints(pinningTo: bottomSheetSuperview,
                                                       edges: .vertical,
                                                       insets: constraintInset),
            currentBottomSheet.contentView.leadingAnchor.constraint(equalTo: bottomSheetSuperview.leadingAnchor),
            currentBottomSheet.contentView.trailingAnchor.constraint(equalTo: bottomSheetSuperview.trailingAnchor)
        ])
    }
}

// MARK: UIGestureRecognizerDelegate
extension BottomSheetNavigationController: UIGestureRecognizerDelegate {
    public override func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool
    ) {
        defer {
            super.navigationController(navigationController, didShow: viewController, animated: animated)
        }

        update(viewController: viewController)
        guard let bottomSheetNavigationController = navigationController as? BottomSheetNavigationController else {
            return
        }
        bottomSheetNavigationController.didViewPushedToStack = false
    }

    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
        if let bottomSheetable = toVC as? BottomSheetable, bottomSheetable.tiersType == .oneTierAutomatic {
            switch operation {
            case .push:
                return TransitionAnimator(for: .presenting)
            case .pop:
                return TransitionAnimator(for: .dismissing)
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return false
        }
        return viewControllers.count > 1 && didViewPushedToStack == false
    }
}

// MARK: BottomSheetable
extension BottomSheetNavigationController: BottomSheetable {

    public var backgroundColor: UIColor { return currentBottomSheet.backgroundColor }
    public var contentView: UIView { return self.view }
    public var verticalScrollViews: [UIScrollView] { return currentBottomSheet.verticalScrollViews }
    public var tiersType: BottomSheetTierType { return currentBottomSheet.tiersType }
    public var startingTier: BottomSheetTier { return currentBottomSheet.startingTier }
    public var shouldHideGrabber: Bool { return currentBottomSheet.shouldHideGrabber }
    public var isKeyboardObserver: Bool { return currentBottomSheet.isKeyboardObserver }
    public var isDismissable: Bool { return currentBottomSheet.isDismissable }

    public func dismissCompletion() {
        currentBottomSheet.dismissCompletion()
    }

    public func shouldDismiss(completion: @escaping (Bool) -> Void) {
        currentBottomSheet.shouldDismiss(completion: completion)
    }

    public var useSafeArea: Bool {
        self.currentBottomSheet.useSafeArea
    }
}
