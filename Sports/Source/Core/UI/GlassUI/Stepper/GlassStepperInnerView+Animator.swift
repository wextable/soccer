//
//  GlassStepperInnerView+Animator.swift
//  GlassUI
//
//  Created by Alex Johnson on 7/21/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import class Combine.AnyCancellable
import UIKit

extension GlassStepperInnerView {
    /// A utility for animating changes between states of a view. See `GlassStepperInnerView` for example usage.
    struct Animator {
        private let layoutRoot: UIView
        private let animate: (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void
        private var hasLayoutChanges = false
        private var prepareActions: [() -> Void] = []
        private var applyActions: [() -> Void] = []
        private var cleanupActions: [() -> Void] = []

        init(layoutRoot: UIView) {
            self.layoutRoot = layoutRoot
            self.animate = { UIView.animate(withDuration: $0, animations: $1, completion: $2) }
        }

        #if DEBUG
        init(layoutRoot: UIView,
             animate: @escaping (TimeInterval, @escaping () -> Void, @escaping (Bool) -> Void) -> Void) {
            self.layoutRoot = layoutRoot
            self.animate = animate
        }
        #endif

        mutating func updateHidden(of view: UIView, _ oldValue: Bool?, _ newValue: Bool) {
            guard oldValue != newValue else {
                return
            }

            prepareActions.append {
                view.alpha = (newValue ? 1 : 0)
                view.isHidden = false
            }

            applyActions.append {
                view.alpha = (newValue ? 0 : 1)
            }

            cleanupActions.append {
                view.isHidden = newValue
                view.alpha = 1
            }
        }

        mutating func updateActive(of constraint: NSLayoutConstraint, _ oldValue: Bool?, _ newValue: Bool) {
            guard oldValue != newValue else {
                return
            }

            hasLayoutChanges = true
            applyActions.append {
                constraint.isActive = newValue
            }
        }

        mutating func updateConstant(of constraint: NSLayoutConstraint, _ newValue: CGFloat) {
            let oldValue = constraint.constant

            guard oldValue != newValue else {
                return
            }

            hasLayoutChanges = true
            applyActions.append {
                constraint.constant = newValue
            }
        }

        mutating func apply(affectsLayout: Bool = false, action: @escaping () -> Void) {
            if affectsLayout {
                hasLayoutChanges = true
            }
            applyActions.append(action)
        }

        func run(duration: TimeInterval) -> AnyCancellable? {
            guard !prepareActions.isEmpty || !applyActions.isEmpty || !cleanupActions.isEmpty else {
                return nil
            }

            var cancelled = false

            if hasLayoutChanges {
                layoutRoot.layoutIfNeeded()
            }

            prepareActions.forEach { $0() }

            /*UIView.*/animate(
                /*withDuration: */duration,
                /*animations: */{
                    guard !cancelled else { return }

                    self.applyActions.forEach{ $0() }

                    if self.hasLayoutChanges {
                        self.layoutRoot.layoutIfNeeded()
                    }
                },
                /*completion: */{ finished in
                    guard finished && !cancelled else {
                        return
                    }

                    self.cleanupActions.forEach { $0() }
                }
            )

            return AnyCancellable({ cancelled = true })
        }
    }
}
