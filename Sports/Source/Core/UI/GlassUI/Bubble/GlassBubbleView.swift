//
//  GlassBubbleView.swift
//  GlassUI
//
//  Created by Vishal Madheshia on 06/10/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// MARK: - GlassBubbleView class implementation -
// This component will be removed, it is not considered a core component
public class GlassBubbleView: BaseView {

    // MARK: Variables

    // Border Color of the bubble
    override open var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor, color != GlassColor.clear.uiColor else { return }
            model.backgroundColor = color
            backgroundColor = GlassColor.clear.uiColor
        }
    }

    fileprivate var arrowTip: CGPoint = .zero

    public var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization
    public init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        self.backgroundColor = GlassColor.clear.uiColor
        self.isAccessibilityElement = false
        applyModel()
    }

    private func applyModel() {
        arrowTip = CGPoint(x: model.arrowTipXPosition, y: 0)
        setNeedsDisplay()
    }

    // MARK: Drawing

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let bubbleFrame = getBubbleFrame(rect)

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        drawBubble(bubbleFrame, context: context)
        context.restoreGState()
    }

    private func getBubbleFrame(_ rect: CGRect) -> CGRect {
        let bubbleWidth: CGFloat
        let bubbleHeight: CGFloat
        let bubbleXOrigin: CGFloat
        let bubbleYOrigin: CGFloat
        bubbleWidth = rect.width
        bubbleHeight = rect.height - model.arrowHeight

        bubbleXOrigin = 0
        bubbleYOrigin = model.arrowHeight
        return CGRect(x: bubbleXOrigin, y: bubbleYOrigin, width: bubbleWidth, height: bubbleHeight)
    }

    fileprivate func drawBubble(_ bubbleFrame: CGRect, context: CGContext) {

        let arrowWidth = model.arrowWidth
        let arrowHeight = model.arrowHeight
        let cornerRadius = model.cornerRadius

        let contourPath = CGMutablePath()
        contourPath.move(to: CGPoint(x: arrowTip.x, y: arrowTip.y))

        contourPath.addLine(to: CGPoint(x: arrowTip.x - arrowWidth / 2,
                                        y: arrowTip.y + arrowHeight))
        drawBubbleTopShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)

        contourPath.addLine(to: CGPoint(x: arrowTip.x + arrowWidth / 2,
                                        y: arrowTip.y + arrowHeight))

        contourPath.closeSubpath()
        context.addPath(contourPath)
        context.clip()

        paintBubble(context)

        if model.hasBorder {
            drawBorder(contourPath, context: context)
        }
    }

    fileprivate func drawBubbleTopShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {

        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y),
                    tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    tangent2End: CGPoint(x: frame.x, y: frame.y),
                    radius: cornerRadius)
    }

    fileprivate func paintBubble(_ context: CGContext) {
        context.setFillColor(model.backgroundColor.cgColor)
        context.fill(bounds)
    }

    fileprivate func drawBorder(_ borderPath: CGPath, context: CGContext) {
        context.addPath(borderPath)
        context.setStrokeColor(model.borderColor.cgColor)
        context.setLineWidth(model.borderWidth)
        context.strokePath()
    }
}

// MARK: - GlassBubbleView ViewModel
extension GlassBubbleView {
    /// The model powering the Glass bubble view.
    public struct Model {

        /// X Position for arrow tip to show.
        public var arrowTipXPosition: Int
        ///  Corner radius of the bubble
        public var cornerRadius: CGFloat
        /// Height of the arrow
        public var arrowHeight: CGFloat
        /// Width of the arrow
        public var arrowWidth: CGFloat
        /// Background color of the bubble
        public var backgroundColor: UIColor
        /// Border Width of the bubble
        public var borderWidth: CGFloat
        /// Border Color of the bubble
        public var borderColor: UIColor

        var hasBorder : Bool {
            return borderWidth > 0 && borderColor != GlassColor.clear.uiColor
        }

        public init(arrowTipXPosition: Int = 100,
                    cornerRadius: CGFloat = GlassSpacing.xSmall,
                    arrowHeight: CGFloat = GlassSpacing.xSmall,
                    arrowWidth: CGFloat = 1.5 * GlassSpacing.xSmall,
                    backgroundColor: UIColor = GlassColor.gray10.uiColor,
                    borderWidth: CGFloat = 2,
                    borderColor: UIColor = GlassColor.gray30.uiColor) {
            self.arrowTipXPosition = arrowTipXPosition
            self.cornerRadius = cornerRadius
            self.arrowHeight = arrowHeight
            self.arrowWidth = arrowWidth
            self.backgroundColor = backgroundColor
            self.borderWidth = borderWidth
            self.borderColor = borderColor
        }
    }

}

// MARK: CGRect extension

extension CGRect {
    fileprivate var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.origin.x = newValue
        }
    }

    fileprivate var y: CGFloat {
        get {
            return self.origin.y
        }

        set {
            self.origin.y = newValue
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassBubbleView {
    struct TestHooks {
        let target: GlassBubbleView

        var arrowTip: CGPoint {
            return target.arrowTip
        }

        func getBubbleFrame(_ rect: CGRect) -> CGRect {
            return target.getBubbleFrame(rect)
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }

}
#endif
