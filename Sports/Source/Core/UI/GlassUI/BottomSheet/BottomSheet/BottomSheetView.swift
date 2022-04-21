//
//  BottomSheetView.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/5/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public protocol BottomSheetViewDelegate: AnyObject {
    func scrollToDismissal(at percentage: CGFloat)
}

public protocol BottomSheetableActionDelegate: AnyObject {
    func triggerDismiss(_ sender: BottomSheetable)
    func triggerViewUpdate(_ sender: BottomSheetable)
    @discardableResult
    func updateTier(_ sender: BottomSheetable, change: BottomSheetChange) -> BottomSheetTier
    func triggerPopoverRectUpdate()
}

public extension BottomSheetableActionDelegate {
    func triggerPopoverRectUpdate() {}
}

private let navigationTabHeight: CGFloat = 50
private let navBarBuffer: CGFloat = 6
private let tabHeight: CGFloat = 40
private let navHeight: CGFloat = 44
private let bottomHiddenTailConstant: CGFloat = 100
private let animateInDuration: TimeInterval = GlassAnimation.animationTimeLong
private let animateOutDuration: TimeInterval = GlassAnimation.animationTimeMedium
private let animateMoveDuration: TimeInterval = GlassAnimation.animationTimeShort

/// This enum is available to help with setting values for  objects adopting `BottomSheetable` protocol
///
/// `contentHeightMax` can be used as a default for `maxBottomSheetHeight`
///  parameter in `BottomSheetable`
///
@available(*, deprecated, renamed: "BottomSheetDefaults")
public enum BottomSheetDefaultSize {
    case regular
    case withNav

    public var contentHeightMax: CGFloat {
        let fullSize = UIScreen.main.bounds.size.height - bottomHiddenTailConstant
        switch self {
        case .regular: return fullSize - tabHeight
        case .withNav: return fullSize - navigationTabHeight
        }
    }
}

/// This struct is available for default values for  objects adopting `BottomSheetable` protocol
///
public struct BottomSheetDefaults {

    let applicationSizeable: ApplicationSceneSizeable
    let screen: ScreenSizeable

    public init(applicationSizeable: ApplicationSceneSizeable = UIApplication.shared,
                screenSizeable: ScreenSizeable = UIScreen.main) {
        self.applicationSizeable = applicationSizeable
        self.screen = screenSizeable
    }

    /// Get a default maxHeight for BottomSheet
    ///
    /// # Example
    /// ```swift
    /// var maxBottomSheetHeight: CGFloat {
    ///    BottomSheetDefaults().maxHeight(isEmbeddedInNav: isEmbeddedInNav)
    /// }
    /// ```
    /// - Parameters:
    ///     - isEmbeddedInNav: adjuct height if bottomsheet is embeded in nav controller.  Best to you `isEmbeddedInNav`
    ///     UIViewController extension property
    ///     - adjustToShowBackgroundNav: Adjust height to show nav controller that the bottomSheet is layered on top of
    ///
    public func maxHeight(isEmbeddedInNav: Bool, adjustToShowBackgroundNav: Bool = true) -> CGFloat {
        let notchBuffer: CGFloat = applicationSizeable.hasNotch ? 20 : 0
        let backgroundBuffer = adjustToShowBackgroundNav ? navHeight : 0
        let topBuffer = applicationSizeable.statusBarHeight + notchBuffer + backgroundBuffer
        let totalBuffer = isEmbeddedInNav ?
            topBuffer + navBarBuffer + 8 : topBuffer + navigationTabHeight

        let newHeight = screen.screenHeight - totalBuffer
        return newHeight > 0 ? newHeight : 0
    }
}

public protocol ScreenSizeable {
    var screenHeight: CGFloat { get }
}

extension UIScreen: ScreenSizeable {
    public var screenHeight: CGFloat { return bounds.size.height }
}

public protocol ApplicationSceneSizeable {
    var statusBarHeight: CGFloat { get }
    var hasNotch: Bool { get }
}

extension UIApplication: ApplicationSceneSizeable {
    public var hasNotch: Bool {
        guard let currentWindow = windows.last else { return false }
        return currentWindow.safeAreaInsets.bottom > 0
    }

    public var statusBarHeight: CGFloat {
        guard let scene = windows.last?.windowScene,
            let manager = scene.statusBarManager else { return 0 }
        return manager.statusBarFrame.height
    }
}

class BottomSheetView: BaseView {

    private let bottomContentView = UIView()
    private let tabView = UIView()
    private let grabberView = GrabberView()
    let mainView = UIView()
    private var bottomConstraint: NSLayoutConstraint?
    private var initialPanTouchLocation: CGPoint?

    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var dismissAction: (() -> Void)?

    private let presentationStyle: BottomSheetPresentationStyle
    var isDismissable = true

    private let viewModel: BottomSheetViewModel
    weak var delegate: BottomSheetViewDelegate?

    private var currentBottomConstant: CGFloat { return bottomHiddenTailConstant + viewModel.getExpansionDifference }
    private var contentView: UIView { return viewModel.view }

    init(frame: CGRect = .zero,
         bottomSheetItem: BottomSheetable,
         presentationStyle: BottomSheetPresentationStyle = .modal) {
        self.presentationStyle = presentationStyle
        self.viewModel = BottomSheetViewModel(bottomSheetConfig: bottomSheetItem)
        switch presentationStyle {
        case .child(let isDismissable):
            self.isDismissable = isDismissable
        default:
            self.isDismissable = bottomSheetItem.isDismissable
        }
        super.init(frame: frame)
        bottomSheetItem.bottomSheetableActionDelegate = self
    }

    override func constructView() {
        super.constructView()

        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: -8)
        layer.shadowRadius = 8
        layer.masksToBounds = false

        backgroundColor = viewModel.backgroundColor

        let contentPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer = contentPanGesture
        contentPanGesture.delegate = self
        addGestureRecognizer(contentPanGesture)

        bottomContentView.backgroundColor = viewModel.backgroundColor
        mainView.backgroundColor = viewModel.backgroundColor

        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSelfIfAllowed))
        tabView.addGestureRecognizer(tabGesture)

        grabberView.backgroundColor = GlassColor.gray80.uiColor
        grabberView.layer.cornerRadius = 4
        grabberView.layer.masksToBounds = true
        grabberView.isAccessibilityElement = false
        grabberView.accessibilityIdentifier = "grabberView"
        grabberView.accessibilityTraits = .adjustable
        grabberView.accessibilityIncrementCallback = { [weak self] in
            guard let self = self else { return }
            self.handleTierChanged(change: .expand)
        }
        grabberView.accessibilityDecrementCallback = { [weak self] in
            guard let self = self else { return }
            self.handleTierChanged(change: .contract)
        }

        viewModel.updateSubviewVericalScroll()
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        [mainView, tabView, bottomContentView, grabberView].forEach(addAutoLayoutSubview(_:))
        mainView.addAutoLayoutSubview(contentView)
        let tabBarHeight = viewModel.shouldIgnoreTabBar
            ? GlassSpacing.xSmall
            : (viewModel.isNav ? navBarBuffer : tabHeight)
        grabberView.isHidden = viewModel.shouldHideGrabber
        NSLayoutConstraint.activate(
            bottomContentView.topAnchor.constraint(equalTo: mainView.bottomAnchor),
            bottomContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContentView.heightAnchor.constraint(equalToConstant: bottomHiddenTailConstant),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabView.topAnchor.constraint(equalTo: topAnchor),
            tabView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabView.bottomAnchor.constraint(equalTo: mainView.topAnchor),
            tabView.heightAnchor.constraint(equalToConstant: tabBarHeight),
            grabberView.heightAnchor.constraint(equalToConstant: 4),
            grabberView.widthAnchor.constraint(equalToConstant: 32),
            grabberView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            grabberView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor, constant: 0)
        )
        if let defaultExpandedHeight = viewModel.expandedHeight {
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant:
                defaultExpandedHeight).isActive = true
        }
        contentView.heightAnchor.constraint(lessThanOrEqualToConstant:
                viewModel.maxBottomSheetHeight).isActive = true
        NSLayoutConstraint.activate(
            contentView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        )
    }

    internal func setupInside(containerView: UIView, useSafeArea: Bool = false, dismissAction: (() -> Void)? = nil) {
        if !isDescendant(of: containerView) {
            containerView.addAutoLayoutSubview(self)
        }

        let bottomConstant = presentationStyle == .modal ? currentBottomConstant : UIScreen.main.bounds.size.height

        var leadingAnchor = containerView.leadingAnchor
        var trailingAnchor = containerView.trailingAnchor
        if useSafeArea {
            leadingAnchor = containerView.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = containerView.safeAreaLayoutGuide.trailingAnchor
            self.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        NSLayoutConstraint.activate(
            self.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.trailingAnchor.constraint(equalTo: trailingAnchor)
        )
        bottomConstraint = bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: bottomConstant)
        bottomConstraint?.isActive = true
        self.dismissAction = dismissAction
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let superview = superview else {
            assertionFailure("BottomSheetView should always have a superview")
            return
        }
        switch gestureRecognizer.state {
        case .began:
          initialPanTouchLocation = gestureRecognizer.location(in: superview)
          superview.endEditing(true)
        case .cancelled, .failed:
          initialPanTouchLocation = nil
        case .changed:
            guard let initialLocation = initialPanTouchLocation else { return }
            let newLocation = gestureRecognizer.location(in: superview)
            handleChange(initialLocation: initialLocation, newLocation: newLocation)
        case .ended:
            guard let initialLocation = initialPanTouchLocation else { return }
            let newLocation = gestureRecognizer.location(in: superview)
            handleEnd(initialLocation: initialLocation, newLocation: newLocation)
        case .possible: break
        default: break
        }
    }

    private func handleChange(initialLocation: CGPoint, newLocation: CGPoint) {
        let yDifference = newLocation.y - initialLocation.y
        if let percentage = viewModel.getScrollToDismissalPercentage(forYDifference: yDifference,
                                                                     defaultSize: contentView.frame.height) {
          delegate?.scrollToDismissal(at: percentage)
        }

        let difference = currentBottomConstant + yDifference

        guard difference > bottomHiddenTailConstant else { return }
        animateContainerMove(withYDifference: difference, withDuration: animateMoveDuration)
    }

    private func handleTierChanged(change: BottomSheetChange) {
        let (isChange, currentTier) = viewModel.updateTier(change: .init(change: change))
        if isChange {
            animateContainerMove(withYDifference: currentBottomConstant,
                                 withDuration: animateMoveDuration)
            switch currentTier {
            case .minimum:
                self.grabberView.accessibilityLabel = "Swipe up to show more information"
            case .detail:
                self.grabberView.accessibilityLabel =
                    "Swipe up to show more information, or down to show less information"
            case .full:
                self.grabberView.accessibilityLabel = "Show less information"
            }
            UIAccessibility.post(notification: .layoutChanged, argument: self.grabberView)
        }
    }

    private func handleEnd(initialLocation: CGPoint, newLocation: CGPoint) {
        let yDifference = newLocation.y - initialLocation.y
        let currentHeight = viewModel.getHeightForCurrentTier - yDifference
        let isPassedThreshold = viewModel.didPassDismissalThreshold(forContentSize: contentView.frame.height,
                                                                    yDifference: yDifference)
        // Reset the location to current height & attempt to dismiss if it passes threshold
        if isPassedThreshold && isDismissable {
            resetLocation(with: currentHeight, animationDuration: animateInDuration)
            dismissSelfIfAllowed()
        } else {
            resetLocation(with: currentHeight, animationDuration: animateMoveDuration)
        }
        initialPanTouchLocation = nil
    }

    private func resetLocation(with currentHeight: CGFloat, animationDuration: TimeInterval) {
        if !viewModel.isExpandable {
            animateContainerMove(withYDifference: bottomHiddenTailConstant, withDuration: animationDuration)
        } else {
            viewModel.updateTierState(currentHeight: currentHeight)
            animateContainerMove(withYDifference: currentBottomConstant, withDuration: animationDuration)
        }
    }

    @objc internal func dismissSelfIfAllowed() {
        viewModel.shouldDismiss { [weak self] allowed in
            guard let self = self else { return }
            // Dismiss if allowed
            if allowed {
                self.dismissBottomSheetView()
            }
        }
    }

    // Dismisses bottom sheet view
    private func dismissBottomSheetView() {
        guard isDismissable else { return }
        endEditing(true)
        UIView.animate(withDuration: animateOutDuration, animations: {
            self.bottomConstraint?.constant = self.viewModel.maxBottomSheetHeight * 2
            self.delegate?.scrollToDismissal(at: 1)
            self.superview?.layoutIfNeeded()
            }, completion: { _ in
                self.viewModel.cleanUpChildViewController()
                self.removeFromSuperview()
                self.viewModel.dismissCompletion?()
                self.dismissAction?()
        })
    }

    private func animateContainerMove(withYDifference yDifference: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.bottomConstraint?.constant = yDifference
            self.superview?.layoutIfNeeded()
        })
    }

    internal func slideIn(inView view: UIView, withAnimation shouldAnimate: Bool, completion: (() -> Void)? = nil) {
        let animationTime: TimeInterval = shouldAnimate ? animateInDuration : 0
        self.layoutIfNeeded()
        let constant = currentBottomConstant
        UIView.animate(withDuration: animationTime,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.7,
                       options: [.curveEaseOut],
                       animations: {
                        self.bottomConstraint?.constant = constant
                        view.layoutIfNeeded()

        }, completion: { _ in
            completion?()
        })
    }
}

public enum BottomSheetChange {
    case expand
    case contract
}

// MARK: BottomSheetableActionDelegate
extension BottomSheetView: BottomSheetableActionDelegate {
    func updateTier(_ sender: BottomSheetable, change: BottomSheetChange) -> BottomSheetTier {
        let (isChange, currentTier) = viewModel.updateTier(change: .init(change: change))
        if isChange {
            animateContainerMove(withYDifference: currentBottomConstant,
                                 withDuration: animateMoveDuration)
        }
        return currentTier
    }

    func triggerDismiss(_ sender: BottomSheetable) {
        dismissSelfIfAllowed()
    }

    func triggerViewUpdate(_ sender: BottomSheetable) {
        grabberView.isHidden = viewModel.shouldHideGrabber
        backgroundColor = viewModel.backgroundColor
    }
}

// MARK: UIGestureRecognizerDelegate
extension BottomSheetView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollview = otherGestureRecognizer.view as? UIScrollView else { return false }
        guard viewModel.verticalScrollViews.contains(scrollview) else { return false }
        return scrollview.contentOffset.y <= 0
    }
}

// MARK: Debug
#if DEBUG
extension BottomSheetView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: BottomSheetView

        fileprivate init(target: BottomSheetView) {
            self.target = target
        }

        var bottomConstraint: NSLayoutConstraint? { return target.bottomConstraint }
        var currentBottomConstant: CGFloat { target.currentBottomConstant }
        var initialPanTouchLocation: CGPoint? { return target.initialPanTouchLocation }

        func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            target.handlePan(gestureRecognizer)
        }

        func handleChange(initialLocation: CGPoint, newLocation: CGPoint) {
            target.handleChange(initialLocation: initialLocation, newLocation: newLocation)
        }

        func handleEnd(initialLocation: CGPoint, newLocation: CGPoint) {
            target.handleEnd(initialLocation: initialLocation, newLocation: newLocation)
        }
    }
}
#endif
