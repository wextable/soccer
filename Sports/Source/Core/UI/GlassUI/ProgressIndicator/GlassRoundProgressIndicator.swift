//
//  GlassRoundProgressIndicator.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/10/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public class GlassRoundProgressIndicator: UIView {
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat
    var progressLayer: CAShapeLayer?

    let progressLabel: GlassLabel = {
        let label = GlassLabel(style: .heading)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public var percentComplete: Double = 0.0 {
        didSet {
            progressLabel.text = "\(Int(percentComplete))%"
            self.isAccessibilityElement = true
            self.accessibilityTraits = .summaryElement
            self.accessibilityLabel = "\("progress".localize())"
            self.accessibilityValue = "\(Int(percentComplete))%"
            animation(percentComplete: percentComplete)
        }
    }

    public init(circleRadius: CGFloat = GlassSpacing.xLarge / 2) {
        self.circleRadius = circleRadius
        super.init(frame: .zero)
        self.backgroundColor = .clear
        progressLabel.text = "0%"
        percentComplete = 0
        addBackgroundRing()
        postInit()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not defined")
    }

    func setConstraints() {
        self.addSubview(progressLabel)

        let constraints = [
            heightAnchor.constraint(equalToConstant: circleRadius * 2),
            widthAnchor.constraint(equalToConstant: circleRadius * 2),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(constraints)
    }

    func postInit() {
        setConstraints()
    }

    public func addBackgroundRing() {
        CATransaction.begin()

        let layer: CAShapeLayer = CAShapeLayer()
        layer.strokeColor = GlassColor.gray20.uiColor.cgColor
        layer.lineWidth = 6.0
        layer.fillColor = UIColor.clear.cgColor

        let path = getBezierPath(percentComplete: 100)

        layer.path = path.cgPath
        self.layer.addSublayer(layer)
    }

    func getBezierPath(percentComplete: Double) -> UIBezierPath {
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: circleRadius,
                                                                 y: circleRadius),
                                              radius: circleRadius,
                                              startAngle: 0,
                                              endAngle: CGFloat(2 * Double.pi * percentComplete / 100),
                                              clockwise: true)

        return path
    }

    public func animation(percentComplete: Double) {
        CATransaction.begin()

        let path = getBezierPath(percentComplete: percentComplete)

        let transform = CGAffineTransform(translationX: circleRadius,
            y: circleRadius).rotated(by: CGFloat(-Double.pi/2)).translatedBy(x: -circleRadius,
                      y: -circleRadius)

        if progressLayer == nil {
            progressLayer = CAShapeLayer()
            progressLayer!.strokeColor = GlassColor.gray50.uiColor.cgColor
            progressLayer!.lineWidth = 6.0
            progressLayer!.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(progressLayer!)
        }

        let animation = CABasicAnimation(keyPath: "strokeEnd")

        animation.fromValue = 0.0
        animation.toValue = 1.0

        animation.duration = GlassAnimation.animationTimeShort

        CATransaction.setCompletionBlock{

        }

        path.apply(transform)
        progressLayer!.path = path.cgPath

        layer.removeAnimation(forKey: "myStroke")
        layer.add(animation, forKey: "myStroke")

        CATransaction.commit()
    }
}

#if DEBUG
extension GlassRoundProgressIndicator {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: GlassRoundProgressIndicator
        init(target: GlassRoundProgressIndicator) {
            self.target = target
        }

        public var progressLabel: UIView {
            target.progressLabel
        }
    }
}
#endif
