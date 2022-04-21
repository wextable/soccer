//
//  SlideUpContainerViewController.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/5/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

class BottomSheetContainerViewController: BaseViewController {

    enum Constants {
        static let maxDimViewAlpha: CGFloat = 0.5
        static let dimmingViewAnimationDuration: TimeInterval = 0.3
    }

    private var isKeyboardShowing: Bool = false
    private let isKeyboardObserver: Bool
    private let bottomSheetView: BottomSheetView
    private let dimmingView = UIView(
        frame: CGRect(origin: .zero,
                      size: UIScreen.main.bounds.size))

    init(bottomSheet: BottomSheetable) {
        self.bottomSheetView = BottomSheetView(bottomSheetItem: bottomSheet, presentationStyle: .modal)
        self.isKeyboardObserver = bottomSheet.isKeyboardObserver
        super.init(nibName: nil, bundle: nil)
        setupBottomSheetVC(sheet: bottomSheet, useSafeArea: bottomSheet.useSafeArea)
        setupPresentationStyle()
        dimmingView.backgroundColor = UIColor.black
    }

    override func constructView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(emptyDismiss))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        bottomSheetView.delegate = self
    }

    @objc func emptyDismiss() {
        bottomSheetView.dismissSelfIfAllowed()
    }

    private func setupBottomSheetVC(sheet: BottomSheetable, useSafeArea: Bool) {
        addChild(sheet)
        bottomSheetView.setupInside(containerView: view, useSafeArea: useSafeArea) { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        didMove(toParent: sheet)
    }

    private func setupPresentationStyle() {
      providesPresentationContextTransitionStyle = true
      definesPresentationContext = true
      modalTransitionStyle = .coverVertical
      modalPresentationStyle = .overFullScreen
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isKeyboardObserver {
            setupKeyboardObserver()
        }
        if let presentingVC = presentingViewController {
            dimmingView.alpha = 0
            presentingVC.view.addAutoLayoutSubview(dimmingView)
            NSLayoutConstraint.activate(presentingVC.view.constraints(pinningTo: dimmingView))

            UIView.animate(withDuration: animated ? Constants.dimmingViewAnimationDuration : 0) {
                self.dimmingView.alpha = Constants.maxDimViewAlpha
            }
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        if isKeyboardObserver {
            destroyKeyboardObservers()
        }
        super.viewWillDisappear(animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        self.dimmingView.removeFromSuperview()
        super.viewDidDisappear(animated)
    }

}

// Makes sure the tableview tap gesture is not intercepted by the background tap
extension BottomSheetContainerViewController: UIGestureRecognizerDelegate {
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == gestureRecognizer.view
  }
}
extension BottomSheetContainerViewController: BottomSheetViewDelegate {
    func scrollToDismissal(at percentage: CGFloat) {
        let maxPercentage = percentage < 1 ? percentage : 1
        dimmingView.alpha = Constants.maxDimViewAlpha * (1 - maxPercentage)
    }
}

extension BottomSheetContainerViewController: KeyboardObserver {
    func keyboardWillShow(_ notification: Notification) {
        guard let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              !isKeyboardShowing
        else {
            return
        }
        isKeyboardShowing = true
        UIView.animate(withDuration: GlassAnimation.animationTimeShort) {
            self.bottomSheetView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -rect.height)
        }
    }

    func keyboardDidShow(_ notification: Notification) { }
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: GlassAnimation.animationTimeShort) {
            self.bottomSheetView.transform = CGAffineTransform.identity
        }
        isKeyboardShowing = false
    }
}

#if DEBUG
extension BottomSheetContainerViewController {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: BottomSheetContainerViewController

        fileprivate init(target: BottomSheetContainerViewController) {
            self.target = target
        }
        var dimmingView: UIView { return target.dimmingView }
        var isKeyboardShowing: Bool { return target.isKeyboardShowing }
    }
}
#endif
