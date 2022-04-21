//
//  Transition.swift
//  GlassUI
//
//  Created by Jordan Perry on 5/14/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// `Transition` makes it simple to perform an interactive UIViewPropertyAnimation during a view controller transition.
///
/// # Usage
/// **Standard Presentations**
/// You can get standard modal presentation with any curve by just by setting the `transitioningDelegate` to a
/// _retained_ transition object.
///
/// **Interactive Presentations**
/// You can get an interactive transition by setting it up similarly (still with any curve), but then doing the
/// following:
/// 1. Set `isInteractivelyTransitioning` to `true` at the start of the user interaction (e.g. pan began)
/// 2. Update the `fractionComplete` attribute based on the relative change to your animation.
public class Transition: NSObject {
    /// `Direction` of the transition
    public enum Direction {
        case presenting
        case dismissing
    }

    /// A hook for determining when a transition will begin
    public var transitionWillBegin: ((Direction) -> Void)?

    /// A hook for determining when a transition will complete
    public var transitionDidComplete: ((Direction, UIViewAnimatingPosition) -> Void)?

    /// Duration for transition
    public var duration: TimeInterval = 0.5

    /// Timing parameters to use for present
    public var presentingTimingParameters: UITimingCurveProvider?

    /// Timing parameters to use for dismiss
    public var dismissingTimingParameters: UITimingCurveProvider?

    /// The animation handler
    ///
    /// - Parameters:
    ///   - Direction: The direction for this animation
    ///
    /// Defaults to a full "normal" transition
    public var animations: ((Direction) -> Void)?

    /// The frame modifier
    ///
    /// A helper to modify the frame of the modal view before it begins its presentation
    public var modalFrameModifier: ((CGRect) -> CGRect)?

    /// Specify whether the next present/dismiss is interactive.
    ///
    /// This will result in the animator becoming paused.
    public var isInteractivelyTransitioning: Bool = false

    /// Initialize a `Transition` with a view that this takes place
    override public init() {
        super.init()
    }

    private var direction: Direction = .presenting
    private var animator: UIViewImplicitlyAnimating?
}

/// Conform to `UIViewImplicitlyAnimating` and pass all values to our `UIViewImplicitlyAnimating` propery
extension Transition: UIViewImplicitlyAnimating {
    public var state: UIViewAnimatingState {
        animator?.state ?? .inactive
    }

    public var isRunning: Bool {
        animator?.isRunning ?? false
    }

    public var isReversed: Bool {
        get {
            animator?.isReversed ?? false
        }
        set {
            animator?.isReversed = newValue
        }
    }

    public var fractionComplete: CGFloat {
        get {
            animator?.fractionComplete ?? 0.0
        }
        set {
            animator?.fractionComplete = newValue
        }
    }

    public func startAnimation() {
        animator?.startAnimation()
    }

    public func startAnimation(afterDelay delay: TimeInterval) {
        animator?.startAnimation(afterDelay: delay)
    }

    public func pauseAnimation() {
        animator?.pauseAnimation()
    }

    public func stopAnimation(_ withoutFinishing: Bool) {
        animator?.stopAnimation(withoutFinishing)
    }

    public func finishAnimation(at finalPosition: UIViewAnimatingPosition) {
        animator?.finishAnimation(at: finalPosition)
    }

    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        animator?.continueAnimation?(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}

extension Transition: UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate,
    UIViewControllerInteractiveTransitioning
{
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        direction = .presenting
        return self
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        direction = .dismissing
        return self
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        direction = .presenting
        return self
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        direction = .dismissing
        return self
    }

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
            else { return }

        transitionWillBegin?(direction)

        let containerView = transitionContext.containerView
        var timingParameters: UITimingCurveProvider?

        let timing = timingParameters ?? UICubicTimingParameters(animationCurve: .easeInOut)

        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator = propertyAnimator

        propertyAnimator.addAnimations {
            let animations = self.animations ?? { (direction) in
                switch direction {
                case .presenting:
                    var height = transitionContext.finalFrame(for: toViewController).height
                    height -= toViewController.view.safeAreaInsets.bottom

                    toViewController.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -height)

                case .dismissing:
                    fromViewController.view.transform = .identity
                }
            }

            animations(self.direction)
        }
        propertyAnimator.addCompletion { (position) in
            self.handleAnimationCompletion(transitionContext: transitionContext,
                                           position: position,
                                           from: fromViewController,
                                           to: toViewController)
        }

        switch direction {
        case .presenting:
            startPresenting(transitionContext: transitionContext,
                            from: fromViewController,
                            to: toViewController,
                            containerView: containerView,
                            timingParameters: &timingParameters)

        case .dismissing:
            startDismissing(from: fromViewController,
                            to: toViewController,
                            containerView: containerView,
                            timingParameters: &timingParameters)
        }

        propertyAnimator.startAnimation()

        if isInteractivelyTransitioning {
            isInteractivelyTransitioning = false
            propertyAnimator.pauseAnimation()
        }
    }
}

private extension Transition {
    func startPresenting(transitionContext: UIViewControllerContextTransitioning,
                         from fromViewController: UIViewController,
                         to toViewController: UIViewController,
                         containerView: UIView,
                         timingParameters: inout UITimingCurveProvider?)
    {
        let finalToFrame = transitionContext.finalFrame(for: toViewController)
        if let modalFrameModifier = modalFrameModifier {
            toViewController.view.frame = modalFrameModifier(finalToFrame)
        } else {
            // move to vc to bottom of view
            var toFrame = finalToFrame
            toFrame.origin.y = containerView.frame.maxY
            toViewController.view.frame = toFrame
        }

        // add both the presenter and the presented view to the container view. add presenter first so that the
        // presented can slide over top of presenter.
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)

        timingParameters = presentingTimingParameters
    }

    func startDismissing(from fromViewController: UIViewController,
                         to toViewController: UIViewController,
                         containerView: UIView,
                         timingParameters: inout UITimingCurveProvider?)
    {
        // add both the presenter and the presented view to the container view. add presenter first so that the
        // presented can slide down but on top. note that the toViewController is the presenter in the context
        // of dismissing.
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)

        timingParameters = dismissingTimingParameters
    }

    func handleAnimationCompletion(transitionContext: UIViewControllerContextTransitioning,
                                   position: UIViewAnimatingPosition,
                                   from fromViewController: UIViewController,
                                   to toViewController: UIViewController)
    {
        let complete = position == .end
        defer {
            transitionContext.completeTransition(complete)
            self.transitionDidComplete?(self.direction, position)
        }

        // make sure there's a window. if there's not, something is probably wrong, but we will still finish our
        // transition regardless (see above)
        guard let window = transitionContext.containerView.window else {
            return
        }

        switch (direction, complete) {
        case (.presenting, true), (.dismissing, false):
            // in the case of a completed present or a cancelled dismiss, we need to add both the presenter and
            // presented back to the window
            window.addSubview(complete ? fromViewController.view : toViewController.view)
            window.addSubview(complete ? toViewController.view : fromViewController.view)

        case (.presenting, false), (.dismissing, true):
            // in the case of a cancelled presentat or a completed dismiss, we just need to add the from presenter to
            // the window
            window.addSubview(direction == .presenting ? fromViewController.view : toViewController.view)
        }
    }
}

#if DEBUG
extension Transition {
    class TestHooks {
        let target: Transition
        init(target: Transition) {
            self.target = target
        }

        var animator: UIViewImplicitlyAnimating? {
            get {
                target.animator
            }
            set {
                target.animator = newValue
            }
        }

        var direction: Direction {
            get {
                target.direction
            }
            set {
                target.direction = newValue
            }
        }

        func handleAnimationCompletion(transitionContext: UIViewControllerContextTransitioning,
                                       position: UIViewAnimatingPosition,
                                       from fromViewController: UIViewController,
                                       to toViewController: UIViewController)
        {
            target.handleAnimationCompletion(transitionContext: transitionContext,
                                             position: position,
                                             from: fromViewController,
                                             to: toViewController)
        }
    }

    var testHooks: TestHooks {
        .init(target: self)
    }
}
#endif
