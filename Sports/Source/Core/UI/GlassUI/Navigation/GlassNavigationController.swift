//
//  GlassNavigationController.swift
//  GlassUI
//
//  Created by John Liedtke on 9/14/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Combine
import UIKit

/// A navigation controller with conveniences for monitoring the state of the navigation stack.
open class GlassNavigationController: UINavigationController {

    open override var delegate: UINavigationControllerDelegate? {
        didSet {
            assert(self === delegate, "\(type(of: self)) is required to be the navigation delegate.")
        }
    }

    private let didShowSubject = PassthroughSubject<Void, Never>()

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        delegate = self
    }

    public init() {
        super.init(nibName: nil, bundle: nil)

        delegate = self
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UINavigationControllerDelegate

extension GlassNavigationController: UINavigationControllerDelegate {

    open func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool
    ) {
        didShowSubject.send(())
    }
}

extension GlassNavigationController {

    private var currentContext: GlassNavigationContext {
        .init(viewControllers: viewControllers)
    }

    /// Returns a publisher that emits values when the navigation stack changes.
    open func navigationContextPublisher() -> AnyPublisher<GlassNavigationContext, Never> {
        didShowSubject
            .compactMap { [weak self] in self?.currentContext }
            .eraseToAnyPublisher()
    }

    /// Returns a publisher that emits a single value when the provided `viewController` is popped from the navigation
    /// stack. If `viewController` is not currently in the navigation stack, it emits a value immediately and finishes.
    open func popPublisher(for viewController: UIViewController) -> AnyPublisher<GlassNavigationContext, Never> {
        guard currentContext.contains(viewController) else {
            return Just(currentContext).eraseToAnyPublisher()
        }

        return navigationContextPublisher()
            .filter { [weak viewController] in
                guard let viewController = viewController else { return true }
                return !$0.contains(viewController)
            }
            .first()
            .eraseToAnyPublisher()
    }
}

// MARK: - GlassNavigationContext

/// The context of the current navigation stack.
public struct GlassNavigationContext: Equatable {

    /// The current view controllers in the navigation stack
    public var viewControllers: [UIViewController]

    /// The top view controller in the navigation stack.
    public var topViewController: UIViewController? {
        viewControllers.last
    }

    /// Returns whether the view controller is in the navigation stack
    public func contains(_ viewController: UIViewController) -> Bool {
        viewControllers.contains(viewController)
    }

    public init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
}
