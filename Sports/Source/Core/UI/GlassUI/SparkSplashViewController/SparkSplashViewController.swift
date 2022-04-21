//
//  SparkSplashViewController.swift
//  GlassUI
//
//  Created by Jordan Perry on 5/18/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// `SparkSplashViewController` is a way to show a splash view controller that animates a mask to reveal content.
///
/// The use case this is intended for is launching the app
public final class SparkSplashViewController: BaseViewController {

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    enum Constants {
        static let rotationAnimationKeyPath = "transform.rotation"
        static let rotationLayerAnimationKey = "rotation-animation"
        static let rotationFirstAnimationKey = "rotation.first-animation"

        static let growAnimationKeyPath = "transform"
        static let growLayerAnimationKey = "grow.animation"
        static let growAnimationKey = "grow.animation"
        static let sparkDiameter: CGFloat = 68.0
    }

    /// Sets the background color for the view controller. This should be used rather than modifying the view itself.
    public var backgroundColor: UIColor? {
        get {
            backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }

    public var sparkColor: UIColor? {
        get {
            sparkView.fillColor
        }
        set {
            sparkView.fillColor = newValue ?? #colorLiteral(red: 0.9999601245, green: 0.7888247371, blue: 0.1385749578, alpha: 1)
        }
    }

    public var dismissCallback: (() -> Void)?

    private let backgroundView = UIView()
    private let sparkView = SparkView()

    public init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
    }

    private var hasViewAppeared = false

    private var hasCalledStartPulse = false
    private var hasPulseStarted = false

    private var hasCalledStartAnimating = false
    private var hasAnimationStarted = false

    /// Add the splash as a child view controller to a view controller using containment.
    ///
    /// **Discussion**
    /// This allows the splash to be added prior to the window becoming key and visible.
    public func addAsChild(to viewController: UIViewController) {
        viewController.addChild(self)

        viewController.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.constraints(pinningTo: viewController.view!).activate()

        didMove(toParent: viewController)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hasViewAppeared = true

        if hasCalledStartAnimating, !hasAnimationStarted {
            // If we've made it here, we are going to add a short delay so that all of the moving around is less jarring
            // (app launching, screen spinning, growing, etc)
            DispatchQueue.main.asyncAfter(deadline: .now() + GlassAnimation.animationTimeLong) {
                self.startAnimating()
            }
            return
        }

        if hasCalledStartPulse, !hasPulseStarted {
            startPulse()
            return
        }
    }

    public func startPulse() {
        hasCalledStartPulse = true

        guard hasViewAppeared
            else {
                return
        }

        hasPulseStarted = true

        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.sparkView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        })
    }

    /// Starts the animation. This allows you to call this when things have actually loaded.
    public func startAnimating() {
        hasCalledStartAnimating = true

        guard hasViewAppeared else {
            return
        }

        hasAnimationStarted = true

        let sublayers = sparkView.layer.sublayers ?? []
        let duration = 1.0
        let beginTime: CFTimeInterval = CACurrentMediaTime()
        for (idx, layer) in sublayers.enumerated() {
            let rotate = CAKeyframeAnimation(keyPath: Constants.rotationAnimationKeyPath)

            let actualStartRatio = Double(idx) / Double(sublayers.count)
            rotate.keyTimes = [0, actualStartRatio as NSNumber, 1]
            rotate.values = [0, 0, (CGFloat.pi / 3) * CGFloat((sublayers.count - idx))]

            if idx == 0 {
                rotate.delegate = self
                rotate.setValue(true, forKey: Constants.rotationFirstAnimationKey)
            }

            rotate.beginTime = beginTime
            rotate.duration = duration
            rotate.fillMode = .forwards
            rotate.timingFunction = .easeInEaseOutCubic
            rotate.isRemovedOnCompletion = false

            layer.add(rotate, forKey: Constants.rotationLayerAnimationKey)
        }
    }

    public override func constructView() {
        super.constructView()

        view.isOpaque = false
        view.backgroundColor = .clear
        backgroundView.backgroundColor = GlassColor.blue90.uiColor
        sparkView.fillColor = #colorLiteral(red: 0.968627451, green: 0.7921568627, blue: 0.168627451, alpha: 1)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(backgroundView)
        view.addAutoLayoutSubview(sparkView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            backgroundView.constraints(pinningTo: view),

            sparkView.heightAnchor.constraint(equalToConstant: Constants.sparkDiameter),
            sparkView.widthAnchor.constraint(equalToConstant: Constants.sparkDiameter),
            sparkView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sparkView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        )
    }
}

extension SparkSplashViewController: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard !isBeingPresented,
            presentingViewController != nil || parent != nil,
            !isBeingDismissed
            else {
                return
        }

        /// If the app is backgrounded during this animation, the finished flag will be passed in as false.
        if flag,
           anim.value(forKey: Constants.rotationFirstAnimationKey) as? Bool == true
        {
            startGrowAnimation()
        } else {
            dismiss()
        }
    }

    func startGrowAnimation() {
        let sparkViewFrame = sparkView.frame

        let petalPath = UIBezierPath.petalPath(with: sparkViewFrame)
        let maskPath = UIBezierPath(rect: view.bounds)
        maskPath.append(petalPath)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd
        backgroundView.layer.mask = maskLayer

        let beginTime: CFTimeInterval = CACurrentMediaTime()
        let duration = 1.0

        let largestHeight = sparkViewFrame.height * 0.3
        let smallestHeight = largestHeight * 0.5

        let grow = CABasicAnimation(keyPath: Constants.growAnimationKeyPath)
        grow.beginTime = beginTime
        grow.delegate = self
        grow.duration = duration
        grow.fillMode = .forwards
        grow.isRemovedOnCompletion = false
        grow.setValue(true, forKey: Constants.growAnimationKey)
        grow.timingFunction = .easeInEaseOutCubic
        grow.toValue = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .translatedBy(x: 0, y: -largestHeight)
                .scaledBy(x: (view.bounds.height / smallestHeight) * 3, y: (view.bounds.height / smallestHeight) * 3)
                .translatedBy(x: 0, y: largestHeight)
        )
        maskLayer.add(grow, forKey: Constants.growLayerAnimationKey)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = duration / 3
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        fade.timingFunction = .easeInEaseOutCubic
        fade.toValue = 0
        sparkView.layer.add(fade, forKey: "fade")

        sparkView.layer.add(grow, forKey: Constants.growLayerAnimationKey)
    }

    func dismiss() {
        if presentingViewController != nil {
            dismiss(animated: false) {
                self.dismissCallback?()
            }
        } else if self.parent != nil {
            unembedFromParent()
            dismissCallback?()
        }
    }
}

#if DEBUG
extension SparkSplashViewController {
    var testHooks: TestHooks { .init(target: self) }

    class TestHooks {
        private let target: SparkSplashViewController
        init(target: SparkSplashViewController) {
            self.target = target
        }

        var backgroundView: UIView { target.backgroundView }
        var sparkView: SparkView { target.sparkView }
    }
}
#endif
