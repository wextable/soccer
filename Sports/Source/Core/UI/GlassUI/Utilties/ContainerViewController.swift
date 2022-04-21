//
//  ContainerViewController.swift
//  GlassUI
//
//  Created by John Liedtke on 10/20/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Methods for observing the content changes of a `ContainerViewController`.
public protocol ContainerViewContentObserving: AnyObject {

    /// called when the content view controller is about to change
    func container(_ container: ContainerViewController, willChangeToContent content: UIViewController?)

    /// called when the content view controller has changed
    func container(_ container: ContainerViewController, didChangeToContent content: UIViewController?)
}

/// A simple container view controller for swapping child controllers with an optional cross-fade animation.
///
/// - ToDo: Support cool custom view controller transitions.
open class ContainerViewController: BaseViewController {

    /// The current content view controller.
    @Published public private(set) var contentViewController: UIViewController?

    private var queue = Queue<(viewController: UIViewController?, animated: Bool)>()
    private var isSwapInProgress = false

    /// Creates the container with the provided view controller.
    public init(contentViewController: UIViewController? = nil) {
        super.init(nibName: nil, bundle: nil)

        setContentViewController(contentViewController, animated: false)
    }

    /// Sets the content view controller to the provided `newViewController` with an optional cross-fade animation.
    open func setContentViewController(_ newViewController: UIViewController?, animated: Bool = true) {
        guard !isSwapInProgress else {
            queue.enqueue((newViewController, animated))
            return
        }
        isSwapInProgress = true

        let observers = [contentViewController, newViewController].compactMap { $0 as? ContainerViewContentObserving }
        notifyObservers(observers, appearancePhase: .willBecome, withNewContent: newViewController)

        updateViewController(newViewController, animated: animated) { [self] in
            notifyObservers(observers, appearancePhase: .didBecome, withNewContent: newViewController)
            isSwapInProgress = false
            advanceQueue()
        }
    }

    private func advanceQueue() {
        guard let next = queue.dequeue() else { return }

        setContentViewController(next.viewController, animated: next.animated)
    }

    private func updateViewController(
        _ newViewController: UIViewController?,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        guard newViewController !== contentViewController else {
            completion()
            return
        }

        let oldViewController = contentViewController
        contentViewController = newViewController

        oldViewController?.willMove(toParent: nil)

        if let newViewController = newViewController {
            newViewController.view.alpha = 0
            addChild(newViewController)
            view.addAutoLayoutSubview(newViewController.view)
            NSLayoutConstraint.activate(newViewController.view.constraints(pinningTo: view, priority: .required))

            // force layout (otherwise, the view animates from the view origin)
            newViewController.view.frame = .init(origin: .zero, size: view.bounds.size)
            newViewController.view.setNeedsLayout()
            newViewController.view.layoutIfNeeded()
        }

        UIView.animate(
            withDuration: animated ? 0.2 : 0,
            animations: {
                newViewController?.view.alpha = 1.0
                oldViewController?.view.alpha = 0
            },
            completion: { _ in
                oldViewController?.removeFromParent()
                oldViewController?.view.removeFromSuperview()
                newViewController?.didMove(toParent: self)
                completion()
            }
        )
    }
}

extension ContainerViewController {

    private enum AppearancePhase {
        case willBecome
        case didBecome
    }

    private func notifyObservers(
        _ observers: [ContainerViewContentObserving],
        appearancePhase: AppearancePhase,

        withNewContent content: UIViewController?)
    {
        observers.forEach {
            switch appearancePhase {
            case .willBecome:
                $0.container(self, willChangeToContent: content)
            case .didBecome:
                $0.container(self, didChangeToContent: content)
            }
        }
    }
}

private struct Queue<T> {

    private var storage: [T] = []

    mutating func enqueue(_ value: T) {
        storage.append(value)
    }

    mutating func dequeue() -> T? {
        storage.isEmpty ? nil : storage.removeFirst()
    }
}
