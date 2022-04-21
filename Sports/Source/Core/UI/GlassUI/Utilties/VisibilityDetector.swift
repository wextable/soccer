//
//  VisibilityDetector.swift
//  GlassUI
//
//  Created by John Liedtke on 9/3/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import Combine
import UIKit

/// An object that **attempts* to track the visibility of a single view by monitoring various view lifecycle methods.
final class VisibilityDetector {
    typealias DebounceInterval = DispatchQueue.SchedulerTimeType.Stride

    static let defaultDebounce: DebounceInterval = .milliseconds(100)

    /// A publisher that emits the visibility status of the view.
    var visibilityPublisher: AnyPublisher<Bool, Never> {
        visibilitySubject
            .compactMap({ $0 })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private weak var view: UIView?

    private let visibilitySubject: CurrentValueSubject<Bool?, Never>

    private let debounceQueue = DispatchQueue(label: "com.walmart.GlassUI.VisibilityDetector.debounce")
    private let scrollDebounce: DebounceInterval
    private let visibilityThreshold: UIView.VisibilityThreshold

    private var verticalScrollTask: AnyCancellable?
    private var horizontalScrollTask: AnyCancellable?
    private var viewDidAppearTask: AnyCancellable?
    private var viewDidDisappearTask: AnyCancellable?

    /// The vertical scroll view that the view is contained in.
    ///
    /// By default, the `enclosingScrollView` isMonitored.
    var verticalScrollView: UIScrollView? {
        didSet {
            verticalScrollTask = nil
            monitorVerticalScrollView()
        }
    }

    /// The horizontal scroll view the view is contained in.
    ///
    /// The default value is `nil`.
    var horizontalScrollView: UIScrollView? {
        didSet {
            horizontalScrollTask = nil
            monitorHorizontalScrollView()
        }
    }

    /// Creates a new detector object that tracks the visibility of the provided view.
    ///
    /// - Parameters:
    ///   - view: The view to observe visibility changes.
    ///   - scrollDebounce: A debounce interval for reporting visibility changes when the view is contained in a
    ///   - visibilityThreshold: The required visibility for a view to considered visible. The default value
    ///   is `partial`.
    /// scroll view. The default value is `100 ms`.
    init(view: UIView,
         scrollDebounce: DebounceInterval = VisibilityDetector.defaultDebounce,
         visibilityThreshold: UIView.VisibilityThreshold = .partial
    ) {
        self.view = view
        self.scrollDebounce = scrollDebounce
        self.visibilitySubject = .init(nil)
        self.visibilityThreshold = visibilityThreshold
        _ = Self.swizzle

        // immediately attempt to monitor the scroll view
        if view.window != nil {
            monitorVerticalScrollViewIfNeeded()
        }

        let notificationCenter = NotificationCenter.default
        viewDidAppearTask = notificationCenter
            .publisher(for: UIViewController.viewDidAppearNotification)
            .sink { [weak self] notification in
                guard let view = self?.view,
                      let viewController = notification.object as? UIViewController,
                      view.isDescendant(of: viewController.view)
                else { return }

                self?.checkVisibility()
            }

        viewDidDisappearTask = notificationCenter
            .publisher(for: UIViewController.viewDidDisappearNotification)
            .sink { [weak self] _ in
                self?.checkVisibility()
            }

        view.onDidMoveToWindow = { [weak self] window in
            self?.checkVisibility()
            if window != nil {
                self?.monitorVerticalScrollViewIfNeeded()
            }
        }

        checkVisibility()
    }

    private func monitorVerticalScrollViewIfNeeded() {
        guard verticalScrollView == nil else {
            return
        }

        verticalScrollView = view?.enclosingScrollView
    }

    private func checkVisibility() {
        guard let view = view else { return }

        visibilitySubject.send(!view.isViewObscured(visibilityThreshold: visibilityThreshold))
    }

    private func monitorVerticalScrollView() {
        guard verticalScrollTask == nil, let verticalScrollView = verticalScrollView else {
            return
        }

        verticalScrollTask = scrollPublisherTask(for: verticalScrollView)

    }

    private func monitorHorizontalScrollView() {
        guard horizontalScrollTask == nil, let horizontalScrollView = horizontalScrollView else {
            return
        }

        horizontalScrollTask = scrollPublisherTask(for: horizontalScrollView)
    }

    private func scrollPublisherTask(for scrollView: UIScrollView) -> AnyCancellable {
        scrollView
            .publisher(for: \.contentOffset)
            .debounce(for: scrollDebounce, scheduler: debounceQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkVisibility()
            }
    }
}

// MARK: - Swizzling

extension VisibilityDetector {

    /// Swizzles `didMoveToWindow`, `viewDidAppear`, and `viewDidDisappear`.
    static let swizzle: Void = {
        UIView.swizzleInstanceMethod(
            #selector(UIView.didMoveToWindow),
            swizzledSelector: #selector(UIView.swizzled_platform_didMoveToWindow)
        )

        UIViewController.swizzleInstanceMethod(
            #selector(UIViewController.viewDidAppear(_:)),
            swizzledSelector: #selector(UIViewController.swizzled_platform_viewDidAppear(_:))
        )

        UIViewController.swizzleInstanceMethod(
            #selector(UIViewController.viewDidDisappear(_:)),
            swizzledSelector: #selector(UIViewController.swizzled_platform_viewDidDisappear(_:))
        )
    }()
}

extension UIView {

    @objc
    func swizzled_platform_didMoveToWindow() {
        self.swizzled_platform_didMoveToWindow()
        onDidMoveToWindow?(window)
    }
}

extension UIViewController {

    /// Posted when a view controller appears.
    static let viewDidAppearNotification = Notification.Name("viewDidAppear")

    /// Posted when a view controller disappears.
    static let viewDidDisappearNotification = Notification.Name("viewDidDisappear")

    @objc
    func swizzled_platform_viewDidAppear(_ animated: Bool) {
        self.swizzled_platform_viewDidAppear(animated)
        NotificationCenter.default.post(
            .init(name: Self.viewDidAppearNotification, object: self, userInfo: [:])
        )
    }

    @objc
    func swizzled_platform_viewDidDisappear(_ animated: Bool) {
        self.swizzled_platform_viewDidDisappear(animated)
        NotificationCenter.default.post(
            .init(name: Self.viewDidDisappearNotification, object: self, userInfo: [:])
        )
    }
}

private var UIDidMoveToWindowAssociatedObjectKey: UInt8 = 0
private extension UIView {

    var onDidMoveToWindow: ((UIWindow?) -> Void)? {
        get { return objc_getAssociatedObject(self, &UIDidMoveToWindowAssociatedObjectKey) as? ((UIWindow?) -> Void) }
        set {
            objc_setAssociatedObject(
                self,
                &UIDidMoveToWindowAssociatedObjectKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

private extension NSObject {

    /// Swizzles an instance method on an Objective-C object.
    class func swizzleInstanceMethod(_ originalSelector: Selector, swizzledSelector:Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        let didAddMethod = class_addMethod(
            self,
            originalSelector,
            method_getImplementation(swizzledMethod!),
            method_getTypeEncoding(swizzledMethod!)
        )

        if didAddMethod {
            class_replaceMethod(
                self,
                swizzledSelector,
                method_getImplementation(originalMethod!),
                method_getTypeEncoding(originalMethod!)
            )
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}
