//
//  GlassActivityIndicator.swift
//  GlassUI
//
//  Created by Jordan Perry and Timothy Sears on 5/17/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Renders an beautifully animated, Walmart branded activity indicator view. This API was designed to mimick
/// `UIActivityIndicator` API's identically.
///
/// - parameter: `ViewStyle`: Determines the size and rendering style of the activity indicator.
///
/// - returns: `GlassActivityIndicator`
public final class GlassActivityIndicator: BaseView {

    // MARK: Helper Types

    /// Determines the size and rendering style of the activity indicator.
    public enum ViewStyle {
        case medium
        case large
        case largeRounded
    }

    private enum Size {
        static let medium = CGSize(width: GlassSpacing.mediumSmall, height: GlassSpacing.mediumSmall)
        static let large = CGSize(width: GlassSpacing.mediumLarge, height: GlassSpacing.mediumLarge)
        static let largeRounded = CGSize(width: GlassSpacing.large, height: GlassSpacing.large)
    }

    private enum Key: String {
        case animation
    }

    // MARK: Properties

    private let style: ViewStyle
    private let roundedBackgroundView: UIView
    private let sparkView: SparkView

    /// A Boolean value that controls whether the receiver is hidden when the animation is stopped.
    public var hidesWhenStopped: Bool = true

    /// A Boolean value indicating whether the activity indicator is currently running its animation.
    public private(set) var isAnimating: Bool = false

    /// The color for the animating Spark.
    var fillColor: UIColor {
        get { return sparkView.fillColor }
        set { sparkView.fillColor = newValue }
    }

    // MARK: Initialization

    /// Initializes and returns an activity-indicator object.
    public init(style: GlassActivityIndicator.ViewStyle) {
        self.style = style

        roundedBackgroundView = {
            let view = UIView()

            view.backgroundColor = GlassColor.blue100.uiColor
            view.alpha = 0.0

            return view
        }()

        sparkView = {
            let view = SparkView()

            view.initialDrawState = .singlePetal

            return view
        }()

        super.init(frame: .zero)
    }

    // MARK: Layout

    public override var intrinsicContentSize: CGSize {
        switch style {
        case .medium:
            return Size.medium

        case .large:
            return Size.large

        case .largeRounded:
            return Size.largeRounded
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        roundedBackgroundView.layer.cornerRadius = Size.largeRounded.width / 2.0
    }

    // MARK: Construction

    override public func constructView() {
        super.constructView()

        switch style {
        case .medium, .large:
            sparkView.fillColor = GlassColor.gray70.uiColor

        case .largeRounded:
            sparkView.fillColor = GlassColor.spark100.uiColor
            roundedBackgroundView.alpha = 1.0
        }
    }

    override public func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(roundedBackgroundView)
        addAutoLayoutSubview(sparkView)
    }

    override public func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let sparkViewInsets: LayoutConstrainingInsets = style == .largeRounded ? .init(GlassSpacing.xSmall) : .init(0)

        NSLayoutConstraint.activate(
            roundedBackgroundView.constraints(pinningTo: self),
            sparkView.constraints(pinningTo: self, insets: sparkViewInsets)
        )
    }

    // MARK: Animation

    /// Starts the animation of the progress indicator.
    public func startAnimating() {
        guard !isAnimating else { return }

        isAnimating = true
        alpha = 1.0
        spinPetals()
    }

    /// Stops the animation of the progress indicator.
    public func stopAnimating() {
        sparkView.removeAnimations()

        if hidesWhenStopped {
            alpha = 0.0
        }

        isAnimating = false
    }

    private func spinPetals() {
        sparkView.animations { sublayers in
            let duration = 1.0
            for (idx, layer) in sublayers.enumerated() {
                let rotateIn = CAKeyframeAnimation(keyPath: "transform.rotation")
                let midRotation = (CGFloat.pi / 3) * CGFloat(sublayers.count - idx - 1)

                rotateIn.keyTimes = [0, 0.5, 1]
                rotateIn.values = [0, midRotation, CGFloat.pi * 1.99]

                rotateIn.duration = duration
                rotateIn.fillMode = .forwards
                rotateIn.timingFunctions = [.easeInEaseOutCubic, .easeInEaseOutCubic]
                rotateIn.isRemovedOnCompletion = false
                rotateIn.repeatCount = .infinity

                layer.speed = 1
                layer.add(rotateIn, forKey: Key.animation.rawValue)
            }
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassActivityIndicator {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassActivityIndicator

        fileprivate init(target: GlassActivityIndicator) {
            self.target = target
        }

        var sparkView: SparkView { return target.sparkView }
    }
}
#endif
