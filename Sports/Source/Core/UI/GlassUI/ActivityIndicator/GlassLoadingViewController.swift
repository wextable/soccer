//
//  GlassLoadingViewController.swift
//  GlassUI
//
//  Created by John Liedtke on 5/28/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A simple view controller that displays an active and centered `LoadingView`. Particularly useful for "child view
/// controller swapping". For example, if you're utilizing `ContainerViewController`, you can set the
/// `currentViewController` to a `LoadingViewController` instance while an asynchronous task completes. Additionally,
/// you can present an instance modally to block the user from navigating away from a screen while a critical task
/// completes.
public class GlassLoadingViewController: BaseViewController {

    private let loadingView: GlassLoadingView
    private let delay: Delay?

    private weak var savedPresentingViewController: UIViewController?

    /// Returns a newly initialized and configured loading view controller.
    ///
    /// - Parameters:
    ///   - style: The preferred style of the loading indicator. Defaults to `regular`
    ///   - delay: An optional delay before the loading indicator is displayed. Defaults to `nil`
    ///   - backgroundColor: The background color of the loading view. Defaults to `clear`
    public init(
        style: GlassActivityIndicator.ViewStyle = .medium,
        delay: Delay? = nil,
        backgroundColor: UIColor = .clear
    ) {
        self.delay = delay
        loadingView = GlassLoadingView(style: style, backgroundColor: backgroundColor)

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        accessibilityElements = [loadingView]
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(loadingView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(loadingView.constraints(centeringInside: view))
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        savedPresentingViewController = presentingViewController
        displayLoadingIndicator()
    }

    private func displayLoadingIndicator() {
        loadingView.isIndicatorHidden = true

        DispatchQueue.main.asyncAfter(deadline: .now() + (delay?.duration ?? 0)) { [weak self] in
            guard let self = self else { return }

            self.presentingViewController?.view.tintAdjustmentMode = .dimmed
            self.loadingView.isIndicatorHidden = self.isBeingDismissed || self.isMovingFromParent
            self.loadingView.indicatorView.startAnimating()
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        savedPresentingViewController?.view.tintAdjustmentMode = .normal
    }
}

// MARK: - Delay

extension GlassLoadingViewController {

    public enum Delay {
        case standard
        case custom(TimeInterval)

        public var duration: TimeInterval {
            switch self {
            case .standard: return 0.3
            case .custom(let interval): return interval
            }
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassLoadingViewController {
    var testHooks: TestHooks { TestHooks(target: self) }

    struct TestHooks {
        let target: GlassLoadingViewController

        var loadingView: GlassLoadingView { target.loadingView }
    }
}
#endif
