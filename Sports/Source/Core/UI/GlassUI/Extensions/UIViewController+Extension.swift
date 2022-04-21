//
//  UIViewController+Extension.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/5/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension UIViewController {
    /// Presents a view from an object that adopts the BottomSheetable Protocol
    /// in a BottomSheet either as a subview or modally
    ///
    /// [Zeplin Reference](https://zpl.io/VxZkpkX)
    ///
    ///`BottomSheetNavigationController` are not supported in `child` presentation style
    ///
    /// # Example
    /// ```swift
    /// let vc = viewControllerToBePresented()
    /// self.present(bottomSheet: vc, as: .modal, animated: true)
    /// ```
    /// - Parameters:
    ///     - bottomSheet: The object adopting the BottomSheetable Protocol to be presented
    ///     - as: The presentation style either as a modal or subview
    ///     - replaceOnIPadWith: Popover configuration to be used in place of bottomsheets on iPads
    ///     - animated: Wheather the presentation should be animated or not.  Default is `true`
    ///     - completion: The block to execute after the presentation finishes. You may specify nil for this parameter.
    func present(bottomSheet sheet: BottomSheetable,
                 as style: BottomSheetPresentationStyle,
                 replaceOnIPadWith popover: (shouldReplace: Bool,
                                             alignment: PopoverAlignment) = (true, .center),
                 animated: Bool = true,
                 completion: (() -> Void)? = nil) {
        var presentationStyle: BottomSheetPresentationStyle = style
        if UIDevice.current.isIpad(), popover.shouldReplace {
            presentationStyle = .popover(alignment: popover.alignment)
        }

        switch presentationStyle {
        case .modal:
            let slideUp = BottomSheetContainerViewController(bottomSheet: sheet)
            self.present(slideUp, animated: animated, completion: {
                slideUp.view.setNeedsLayout()
                slideUp.view.layoutIfNeeded()

                completion?()
            })
        case .child:
            guard !(sheet is UINavigationController) else {
                assertionFailure("Presenting Navigation Controller as a child is not supported")
                return
            }
            addChild(sheet)
            let bottomView = BottomSheetView(bottomSheetItem: sheet, presentationStyle: style)
            bottomView.setupInside(containerView: view, useSafeArea: sheet.useSafeArea)
            view.layoutIfNeeded()
            bottomView.slideIn(inView: view, withAnimation: animated, completion: completion)
            didMove(toParent: sheet)
        case .standardModal(let presentationStyle):
            let containerViewController = StandardModalContainerViewController(bottomSheet: sheet)
            containerViewController.modalPresentationStyle = presentationStyle
            present(containerViewController, animated: animated, completion: completion)
        case .popover(let alignment):
            let containerViewController = PopoverContainerViewController(bottomSheet: sheet, alignment: alignment)
            containerViewController.popoverPresentationController?.sourceView = self.view
            switch alignment {
            case .center:
                containerViewController
                    .popoverPresentationController?.sourceRect = CGRect(origin: .init(x: view.bounds.midX,
                                                                                      y: view.bounds.midY),
                                                                        size: .zero)
            case .bottomCenter:
                containerViewController
                    .popoverPresentationController?
                    .sourceRect = CGRect(origin: .init(x: view.bounds.midX,
                                                       y: view.bounds.height
                                                        - PopoverContainerViewController
                                                        .popoverBottomAlignmentConstant),
                                         size: .zero)
            }
            present(containerViewController, animated: animated, completion: completion)
        }
    }

    /// This is a convenience method to show snackbar on the viewcontroller
    ///
    /// [Zeplin](https://zpl.io/VD0OL3r)
    ///
    /// # Example
    /// ```swift
    /// let vc = viewController()
    /// vc.showSnackbarView(model: .init(message: "message"))
    /// ```
    ///
    /// - Parameters:
    ///     - model: The configuration model for the snackbar.
    ///     - additionalInsets: Used for positioning the snackbar. Default is 16 horizontal, 8 vertical as per zeplin
    ///     - action: The action to perform when the user taps the action button on the snackbar.
    func showSnackbarView(
        model: GlassSnackbar.Model,
        additionalInsets: LayoutConstrainingInsets = .init(
            vertical: GlassSpacing.xSmall,
            horizontal: GlassSpacing.small
        ),
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let snackbar = GlassSnackbar(model: model, action: action, onDismiss: onDismiss)
        snackbar.showSnackbar(in: self, additionalInsets: additionalInsets)
    }

    var isEmbeddedInNav: Bool { return navigationController != nil }
}

// MARK: - Child VC Embedding

extension UIViewController {

    /// This is a convience method and a counterpart to `unembedFromParent()`.
    /// It first unembeds the `child`, and then adds it as a child of the view controller, while
    /// calling any necessary lifecycle methods.  It then adds the child's `view` as a subview
    /// of the view controller's `view`, and activates any provided `constraints`.
    ///
    /// - Parameters:
    ///     - child: The view controller to be added as a child of this view controller.  If `nil`,
    ///              the function will do nothing.
    ///     - containerView: The view to which the child's view will be added as a subview.
    ///                      Defaults to `self.view`.
    ///     - constraints: Layout constraints to be activated following the embed behavior.
    ///                    Note:  No constraints will be activated other than these.
    ///
    /// - Note: If `child` is `nil`, this method will not function.
    ///
    public func embedChild(_ child: UIViewController?,
                           in containerView: UIView? = nil,
                           withConstraints constraints: [LayoutConstraining]?)
    {
        guard let child = child else { return }

        // 1 - Remove Child
        child.unembedFromParent()

        // 2 - Add Child
        addChild(child) ///  automatically triggers`self.willMove(toParent: nil)`

        // 3 - Add Subview
        let containerView: UIView! = containerView ?? self.view
        containerView.addAutoLayoutSubview(child.view)

        // 4 - Apply Constraints
        if let constraints = constraints {
            NSLayoutConstraint.activate(constraints)
        }

        // 5 - Wrap Up
        child.didMove(toParent: self)
    }

    /// This is a convience method and a counterpart to `unembedFromParent()`.
    /// It first unembeds the `child`, and then adds it as a child of the view controller, while
    /// calling any necessary lifecycle methods.  It then adds the child's `view` as a subview
    /// of the view controller's `view`, forms, and activates a set of constraints based on the
    /// supplied view pinning parameters.
    ///
    /// - Parameters:
    ///     - child: The view controller to be added as a child of this view controller.
    ///     - containerView: The view to which the child's view will be added as a subview.
    ///                      Defaults to `self.view`.
    ///     - anchorable: The view or anchorable to which the `child.view` will be constrained.
    ///                   Defaults to `containerView`.
    ///     - edges: A set of edges to pin the `child.view` to. Defaults to `.all`.
    ///     - insets: Edges that are constrained (by passing a `LayoutConstrainingEdges` set)
    ///               are constrained relative to these insets. Defaults to `0`.
    ///     - priority: UILayoutPriority for all constraints that will be set. Defaults to `requiredCompliant`.
    ///
    /// - Note: If `child` is `nil`, this method will not function.
    ///
    public func embedChild(_ child: UIViewController?,
                           in containerView: UIView? = nil,
                           pinnedTo anchorable: LayoutAnchorable? = nil,
                           pinEdges edges: LayoutConstrainingEdges = .all,
                           pinInsets insets: LayoutConstrainingInsets = 0,
                           pinPriority priority: UILayoutPriority = .requiredCompliant)
    {
        guard let child = child else { return }

        // 1 - Construct Constraints
        var constraints: [LayoutConstraining]?
        let containerView = containerView ?? self.view
        if let anchorable = anchorable ?? containerView {
            constraints = [child.view.constraints(pinningTo: anchorable,
                                                 edges: edges,
                                                 insets: insets,
                                                 priority: priority)]
        }

        // 2 - Embed with Constraints
        embedChild(child, in: containerView, withConstraints: constraints)
    }

    /// This is a convience method and counterpart to `embedChild(...)`.
    /// It  removes the view controlller from its parent and the view from its superview.
    /// as well as calling any necessary lifecycle methods.
    ///
    /// - Note: If `parent` is `nil`, this method will not function.
    ///
    public func unembedFromParent() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent() ///  automatically triggers`self.didMove(toParent: nil)`
    }
}

/// Different presentation styles supported by BottomSheet
///  - child: BottomSheetable is added as a child on the presenting VC. Doesn't support NavigationControllers 
///  - modal: BottomSheetable is embedded into BottomSheetContainerViewController and presented upto different
///  heights(tiers) with behaviors as defined by the BottomSheetable
///  - standardModal: Traditional standard modals with presentation styles as passed
///  - popover: Popovers are iPad only.
///  They replace the bottom sheet to show the content in a popover with specified alignments
public enum BottomSheetPresentationStyle: Equatable {
    case child(isDismissable: Bool = true)
    case modal
    case standardModal(presentationStyle: UIModalPresentationStyle = .automatic)
    case popover(alignment: PopoverAlignment = .center)
}

/// Alignment for popovers on iPads. Default is set to Center in BottomSheetPresentationStyle.popover
public enum PopoverAlignment: Equatable {
    case center
    case bottomCenter
}
