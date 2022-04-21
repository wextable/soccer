//
//  StackViewController.swift
//  GlassUI
//
//  Created by Nate Rivard on 5/24/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import UIKit

open class StackViewController: BaseViewController {

    /// The arranged view controllers. use addArrangedChild(_:) or removeArrangedChild(_:) to add or remove
    /// arranged view controllers. If subclassing, it is undefined what happens if you return a different array of
    /// `arrangedChildren` than what is being stored underneath. This field is also KVO compliant and can be observed
    /// to respond to changes
    @objc dynamic open private(set) var arrangedChildren: [UIViewController] = []

    /// The scroll view that the stack view is embedded in. If content is smaller than the view controller's view/scroll
    /// view, that content is only takes up it's true implicit size and bouncing is off (on iOS 12). Otherwise,
    /// scrolling and bouncing is enabled. If `allowsTapsToPassThroughScrollView` is true the scroll view will allow
    /// taps to pass through to content behind the scroll view when none of it's decendents catch the tap.
    @objc dynamic public let scrollView: UIScrollView

    /// The stack view that each arrangedViewController.view is arranged in. Don't remove an arrangedViewController's
    /// view directly, use remove(viewController:) instead. You can, however, add/remove non-view controller content
    /// directly, change spacing, etc.
    public let stackView = UIStackView()

    private var observers = [NSKeyValueObservation]()
    private var stackViewHeightConstraint: NSLayoutConstraint?

    public init(arrangedChildren: [UIViewController] = [], allowsTapsToPassThroughScrollView: Bool = false) {
        self.scrollView = allowsTapsToPassThroughScrollView ? PassThroughScrollView() : UIScrollView()

        super.init(nibName: nil, bundle: nil)

        // addArrangedChild(_:) actually manages self.arrangedChildren, so don't set it explicitly above
        arrangedChildren.forEach { addArrangedChild($0) }
    }

    open override func constructView() {
        super.constructView()

        stackView.axis = .vertical
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        stackViewHeightConstraint?.isActive = !scrollView.isScrollEnabled

        observers = [
            observe(\.scrollView.isScrollEnabled) { stackViewController, isScrollEnabled in
                stackViewController.stackViewHeightConstraint?.isActive = !(isScrollEnabled.newValue ?? true)
                stackViewController.view.layoutIfNeeded()
            }
        ]
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        observers.removeAll()
    }

    open override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(scrollView)
        scrollView.addAutoLayoutSubview(stackView)
    }

    open override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        stackViewHeightConstraint = stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            .with(priority: .requiredCompliant)
        stackViewHeightConstraint?.isActive = !scrollView.isScrollEnabled

        NSLayoutConstraint.activate(
            scrollView.topAnchor.constraint(equalTo: view.topAnchor).with(priority: .requiredCompliant),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).with(priority: .requiredCompliant),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.constraints(pinningTo: scrollView)
        )
    }

    /// Adding view controller as a child, and inserting its view into the stack view at specific index.
    open func insertArrangedChild(_ viewController: UIViewController, at index: Int) {
        arrangedChildren.insert(viewController, at: index)

        addChild(viewController)
        stackView.insertArrangedSubview(viewController.view, at: index)
        viewController.didMove(toParent: self)
    }

    /// Add an arranged child view controller.
    open func addArrangedChild(_ viewController: UIViewController) {
        arrangedChildren.append(viewController)

        addChild(viewController)
        stackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    /// Remove an arranged child view controller.
    open func removeArrangedChild(_ viewController: UIViewController) {
        guard let index = arrangedChildren.firstIndex(of: viewController) else { return }

        arrangedChildren.remove(at: index)

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension StackViewController {

    /// Convenience to remove a child view controller at a particular index.
    public func removeArrangedChild(at index: Int) {
        removeArrangedChild(arrangedChildren[index])
    }

    /// Convenience to remove all arranged child view controllers.
    public func removeAllArrangedChildren() {
        arrangedChildren.forEach { removeArrangedChild($0) }
    }

    /// Convenience to remove all arranged child view controllers and non-view-controller subviews
    public func removeAllSubviews() {
        removeAllArrangedChildren()
        stackView.subviews.forEach { $0.removeFromSuperview() }
    }
}
