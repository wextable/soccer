//
//  SparkView.swift
//  GlassUI
//
//  Created by Jordan Perry on 5/18/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// MARK: - SparkView

internal class SparkView: UIView {

    // MARK: Helper Types

    enum DrawState {
        case singlePetal
        case fullSpark
    }

    // MARK: Properties

    var fillColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }

    var isAnimating: Bool = false

    var initialDrawState: DrawState = .fullSpark {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }

    func configureView() {
        backgroundColor = UIColor.clear
    }

    // MARK: Layout

    private var petalLayers: [CALayer] = []
    private var animations: (([CALayer]) -> Void)?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if rect != previousRect {
            fillColor.set()
            previousRect = rect
            refreshPetalLayers(rect)
            animations?(petalLayers)
        }
    }

    private var previousRect = CGRect.zero

    private func refreshPetalLayers(_ rect: CGRect) {
        petalLayers.forEach({ $0.removeFromSuperlayer() })
        petalLayers = []

        let petalPath = UIBezierPath.petalPath(with: rect)
        for idx in stride(from: 0, to: 2 * CGFloat.pi, by: CGFloat.pi / 3) {
            // Move origin to center of the circle
            petalPath.apply(CGAffineTransform(translationX: -rect.midX, y: -rect.midY))

            // Rotate
            if idx != 0 && initialDrawState == .fullSpark {
                petalPath.apply(CGAffineTransform(rotationAngle: CGFloat.pi / 3))
            }

            // Move origin back to original location
            petalPath.apply(CGAffineTransform(translationX: rect.midX, y: rect.midY))

            let shape = CAShapeLayer()

            shape.frame = self.layer.bounds
            shape.path = petalPath.cgPath
            shape.fillColor = fillColor.cgColor

            layer.addSublayer(shape)
            petalLayers.append(shape)
        }
    }

    func animations(_ animations: @escaping ([CALayer]) -> Void) {
        self.animations = animations
        animations(petalLayers)
    }

    func removeAnimations() {
        animations = nil
        petalLayers.forEach {
            $0.speed = 0
            $0.removeAllAnimations()
        }
    }
}

// MARK: - UIBezierPath+Petal

internal extension UIBezierPath {
    static func petalPath(with rect: CGRect) -> UIBezierPath {

        let petalSpread = rect.height / 6.0
        let originX = rect.minX
        let originY = rect.minY
        let height = (rect.height / 2.0) - petalSpread
        let width = height * 0.403
        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0.172 * width + originX, y: 0.04 * height + originY))
        path.addCurve(
            to: CGPoint(x: 0.5 * width + originX, y: 0.003 * height + originY),
            controlPoint1: CGPoint(x: 0.336 * width + originX, y: originY),
            controlPoint2: CGPoint(x: 0.5 * width + originX, y: 0.003 * height + originY)
        )
        path.addCurve(
            to: CGPoint(x: 0.825 * width + originX, y: 0.04 * height + originY),
            controlPoint1: CGPoint(x: 0.5 * width + originX, y: 0.003 * height + originY),
            controlPoint2: CGPoint(x: 0.689 * width + originX, y: 0.003 * height + originY)
        )
        path.addCurve(
            to: CGPoint(x: width + originX, y: 0.119 * height + originY),
            controlPoint1: CGPoint(x: 0.967 * width + originX, y: 0.072 * height + originY),
            controlPoint2: CGPoint(x: width + originX, y: 0.12 * height + originY)
        )
        path.addLine(to: CGPoint(x: 0.828 * width + originX, y: 0.917 * height + originY))
        path.addCurve(
            to: CGPoint(x: 0.701 * width + originX, y: 0.977 * height + originY),
            controlPoint1: CGPoint(x: 0.828 * width + originX, y: 0.917 * height + originY),
            controlPoint2: CGPoint(x: 0.803 * width + originX, y: 0.954 * height + originY)
        )
        path.addCurve(
            to: CGPoint(x: 0.5 * width + originX, y: height + originY),
            controlPoint1: CGPoint(x: 0.607 * width + originX, y: height + originY),
            controlPoint2: CGPoint(x: 0.5 * width + originX, y: height + originY)
        )
        path.addCurve(
            to: CGPoint(x: 0.279 * width + originX, y: 0.977 * height + originY),
            controlPoint1: CGPoint(x: 0.5 * width + originX, y: height + originY),
            controlPoint2: CGPoint(x: 0.36 * width + originX, y: 0.998 * height + originY)
        )
        path.addCurve(
            to: CGPoint(x: 0.172 * width + originX, y: 0.917 * height + originY),
            controlPoint1: CGPoint(x: 0.197 * width + originX, y: 0.956 * height + originY),
            controlPoint2: CGPoint(x: 0.172 * width + originX, y: 0.917 * height + originY)
        )
        path.addLine(to: CGPoint(x: originX, y: 0.132 * height + originY))
        path.addCurve(
            to: CGPoint(x: 0.172 * width + originX, y: 0.04 * height + originY),
            controlPoint1: CGPoint(x: originX, y: 0.132 * height + originY),
            controlPoint2: CGPoint(x: 0.008 * width + originX, y: 0.079 * height + originY)
        )
        path.close()

        let xPosition = rect.width / 2 - width / 2
        let yPosition = rect.height / 2 - height - petalSpread

        path.apply(
            CGAffineTransform(
                translationX: xPosition,
                y: yPosition
            )
        )

        return path
    }
}
