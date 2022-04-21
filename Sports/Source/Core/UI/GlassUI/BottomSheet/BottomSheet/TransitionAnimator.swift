//
//  TransitionAnimator.swift
//  GlassUI
//
//  Created by Zachary Heusinkveld on 10/8/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    enum Mode {
        case presenting, dismissing
    }

    private let duration: TimeInterval
    private let mode: Mode

    init(for mode: Mode, duration: TimeInterval = GlassAnimation.animationTimeShort) {
        self.duration = duration
        self.mode = mode
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        resize(using: transitionContext)
    }

    private func resize(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        do {
            toView.frame = fromView.frame
            toView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(toView)
            NSLayoutConstraint.activate(
                container.bottomAnchor.constraint(equalTo: toView.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: toView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: toView.trailingAnchor)
            )
            if toViewController.preferredContentSize.height > 0 {
                switch mode {
                case .presenting:
                    toView.heightAnchor.constraint(
                        equalToConstant: toViewController.preferredContentSize.height
                    ).activate()
                case .dismissing:
                    fromView.heightAnchor.constraint(
                        equalToConstant: fromViewController.preferredContentSize.height
                    ).activate()
                }
            }
            UIView.animate(withDuration: duration) {
                fromView.alpha = 0
                toView.alpha = 1
            }
        }
        do {
            let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
            let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)

            container.addSubview(fromView)

            switch mode {
            case .presenting:
                toView.transform = offScreenRight
                UIView.animate(withDuration: duration,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: [],
                               animations: {
                                fromView.transform = offScreenLeft
                                toView.transform = CGAffineTransform.identity
                               }, completion: { finished in
                                transitionContext.completeTransition(finished)
                               })
            case .dismissing:
                toView.transform = offScreenLeft
                UIView.animate(withDuration: duration,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: [],
                               animations: {
                                fromView.transform = offScreenRight
                                toView.transform = CGAffineTransform.identity
                               }, completion: { finished in
                                transitionContext.completeTransition(finished)
                               })
            }
        }
        do {
            container.layoutIfNeeded()
            guard let navBar = toViewController.navigationController?.navigationBar else { return }
            var navBarFrame = navBar.frame
            switch mode {
            case .presenting:
                navBarFrame.origin.y = toView.frame.origin.y - navBarFrame.size.height
            case .dismissing:
                navBarFrame.origin.y = fromView.frame.origin.y - navBarFrame.size.height
            }
            UIView.animate(withDuration: duration) {
                navBar.frame = navBarFrame
            }
        }
    }
}

#if DEBUG
extension TransitionAnimator {
    var testHooks: TestHooks { TestHooks(target: self) }

    struct TestHooks {
        private let target: TransitionAnimator

        fileprivate init(target: TransitionAnimator) {
            self.target = target
        }

        var mode: Mode { target.mode }
    }
}
#endif
