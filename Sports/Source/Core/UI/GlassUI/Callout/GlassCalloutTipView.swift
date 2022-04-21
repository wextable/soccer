//
//  GlassCalloutTipView.swift
//  GlassUI
//
//  Created by Hemanth on 12/10/21.
//  Copyright © 2019 Walmart. All rights reserved.
//

import UIKit

// swiftlint:disable line_length

protocol GlassCalloutTipViewDelegate: AnyObject {
    func didTapOnCalloutView(_ calloutView : GlassCalloutTipView)
    func handleTapEvent(at point: CGPoint)
}

// MARK: - Public methods extension

extension GlassCalloutTipView {

    // MARK: Class methods
    /**
     Presents an GlassCalloutTipView pointing to a particular UIView instance within the specified superview
     
     - parameter animated:    Pass true to animate the presentation.
     - parameter view:        The UIView instance which the GlassCalloutTipView will be pointing to.
     - parameter superview:   A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the GlassCalloutTipView within the main window.
     - parameter contentView: The view to be displayed.
     - parameter preferences: The preferences which will configure the GlassCalloutTipView.
     - parameter delegate:    The delegate.
     */
    class func show(animated: Bool = true,
                    forView view: UIView,
                    withinSuperview superview: UIView? = nil,
                    contentView: UIView,
                    preferences: Preferences = GlassCalloutTipView.globalPreferences,
                    delegate: GlassCalloutTipViewDelegate? = nil){

        let ev = GlassCalloutTipView(contentView: contentView, preferences: preferences, delegate: delegate)
        ev.show(animated: animated, forView: view, withinSuperview: superview)
    }

    /**
     Presents an GlassCalloutTipView pointing to a particular UIView instance within the specified superview
     
     - parameter animated:  Pass true to animate the presentation.
     - parameter view:      The UIView instance which the GlassCalloutTipView will be pointing to.
     - parameter superview: A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the GlassCalloutTipView within the main window.
     */
    func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil) {

        let superview = superview ?? UIApplication.shared.windows.first!

        let initialTransform = preferences.animating.showInitialTransform
        let finalTransform = preferences.animating.showFinalTransform
        let initialAlpha = preferences.animating.showInitialAlpha
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity

        presentingView = view
        arrange(withinSuperview: superview)

        transform = initialTransform
        alpha = initialAlpha

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView))
        addGestureRecognizer(tap)

        superview.addSubview(self)

        let animations: () -> Void = {
            self.transform = finalTransform
            self.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: animations, completion: nil)
        } else {
            animations()
        }

        addInteractionViewIfNeeded(with: superview)
    }

    /**
     Dismisses the GlassCalloutTipView
     
     - parameter completion: Completion block to dismiss.
     */
    func dismiss(withCompletion completion: (() -> Void)? = nil){

        removeInteractionViewIfAdded()
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity
        UIView.animate(withDuration: preferences.animating.dismissDuration,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: [.curveEaseInOut],
                       animations: {
                        self.transform = self.preferences.animating.dismissTransform
                        self.alpha = self.preferences.animating.dismissFinalAlpha
        }, completion: { _ in
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            completion?()
        })
    }
}

// MARK: - GlassCalloutTipView class implementation -

class GlassCalloutTipView: UIView {

    // MARK: Nested types -

    struct Preferences {

        struct Drawing {
            var cornerRadius        = CGFloat(1)
            var arrowHeight         = CGFloat(GlassSpacing.xxSmall)
            var arrowWidth          = CGFloat(GlassSpacing.xSmall)
            var backgroundColor     = UIColor.red
            var arrowPosition       = GlassCalloutView.ArrowDirection.any
        }

        struct Animating {
            var dismissTransform     = CGAffineTransform(scaleX: 0.1, y: 0.1)
            var showInitialTransform = CGAffineTransform(scaleX: 0, y: 0)
            var showFinalTransform   = CGAffineTransform.identity
            var springDamping        = CGFloat(0.7)
            var springVelocity       = CGFloat(0.7)
            var showInitialAlpha     = CGFloat(0)
            var dismissFinalAlpha    = CGFloat(0)
            var showDuration         = 0.7
            var dismissDuration      = 0.7
        }

        var drawing      = Drawing()
        var animating    = Animating()

        init() {}
    }

    // MARK: Variables

    override open var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor, color != UIColor.clear else { return }

            preferences.drawing.backgroundColor = color
            backgroundColor = UIColor.clear
        }
    }

    fileprivate weak var presentingView: UIView?
    fileprivate weak var delegate: GlassCalloutTipViewDelegate?
    fileprivate var arrowTip = CGPoint.zero
    fileprivate(set) open var preferences: Preferences
    private let contentView: UIView
    private var interactionView: InteractionView?

    // MARK: - Lazy variables -
    fileprivate lazy var tipViewSize: CGSize = {

        [unowned self] in

        var width = contentView.frame.width
        var height = contentView.frame.height
        switch preferences.drawing.arrowPosition {
        case .left, .right:
            width += self.preferences.drawing.arrowHeight
        default:
            height += preferences.drawing.arrowHeight
        }
        return CGSize(width: width, height: height)
    }()

    // MARK: - Static variables -

    public static var globalPreferences = Preferences()

    // MARK: Initializer

    required public init (contentView: UIView,
                          preferences: Preferences = GlassCalloutTipView.globalPreferences,
                          delegate: GlassCalloutTipViewDelegate? = nil) {
        self.contentView = contentView
        self.preferences = preferences
        self.delegate = delegate

        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.clear
        self.isAccessibilityElement = true

        let notificationName = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation),
                                               name: notificationName,
                                               object: nil)

        isAccessibilityElement = false
    }

    deinit
    {
        removeInteractionViewIfAdded()
        NotificationCenter.default.removeObserver(self)
    }

    /**
     NSCoding not supported. Use init(text, preferences, delegate) instead!
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text, preferences, delegate) instead!")
    }

    // MARK: - Rotation support -

    @objc func handleRotation() {
        guard let sview = superview, presentingView != nil else { return }

        UIView.animate(withDuration: 0.3) {
            self.arrange(withinSuperview: sview)
            self.setNeedsDisplay()
        }
    }

    // MARK: - Private methods -

    fileprivate func computeFrame(arrowPosition position: GlassCalloutView.ArrowDirection,
                                  refViewFrame: CGRect,
                                  superviewFrame: CGRect) -> CGRect {
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0

        switch position {
        case .top, .any:
            xOrigin = refViewFrame.center.x - tipViewSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height + GlassSpacing.xxSmall
        case .topLeft:
            xOrigin = refViewFrame.center.x - (GlassSpacing.small + GlassSpacing.xSmall)
            yOrigin = refViewFrame.y + refViewFrame.height + GlassSpacing.xxSmall
        case .topRight:
            xOrigin = refViewFrame.center.x - tipViewSize.width + (GlassSpacing.small + GlassSpacing.xSmall)
            yOrigin = refViewFrame.y + refViewFrame.height + GlassSpacing.xxSmall
        case .bottom:
            xOrigin = refViewFrame.center.x - tipViewSize.width / 2
            yOrigin = refViewFrame.y - tipViewSize.height - GlassSpacing.xxSmall
        case .bottomLeft:
            xOrigin = refViewFrame.center.x - (GlassSpacing.small + GlassSpacing.xSmall)
            yOrigin = refViewFrame.y - tipViewSize.height - GlassSpacing.xxSmall
        case .bottomRight:
            xOrigin = refViewFrame.center.x - tipViewSize.width + (GlassSpacing.small + GlassSpacing.xSmall)
            yOrigin = refViewFrame.y - tipViewSize.height - GlassSpacing.xxSmall
        case .right:
            xOrigin = refViewFrame.x - tipViewSize.width - GlassSpacing.xxSmall
            yOrigin = refViewFrame.center.y - tipViewSize.height / 2
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width + GlassSpacing.xxSmall
            yOrigin = refViewFrame.center.y - tipViewSize.height / 2
        }

        let frame = CGRect(x: xOrigin, y: yOrigin, width: tipViewSize.width, height: tipViewSize.height)
        return frame
    }

    fileprivate func isFrameValid(_ frame: CGRect, forRefViewFrame: CGRect, withinSuperviewFrame: CGRect) -> Bool {
        if frame.x < GlassSpacing.small {
            return false
        } else if frame.y < GlassSpacing.small {
            return false
        } else if frame.maxX > withinSuperviewFrame.maxX - GlassSpacing.small {
            return false
        } else if frame.maxY > withinSuperviewFrame.maxY - GlassSpacing.small {
            return false
        }
        return !frame.intersects(forRefViewFrame)
    }

    fileprivate func arrange(withinSuperview superview: UIView) {

        var position = preferences.drawing.arrowPosition

        let refViewFrame = presentingView!.convert(presentingView!.bounds, to: superview)

        let superviewFrame = visibleFrame(for: superview)
        var frame = computeFrame(arrowPosition: position, refViewFrame: refViewFrame, superviewFrame: superviewFrame)

        if !isFrameValid(frame,
                         forRefViewFrame: refViewFrame,
                         withinSuperviewFrame: superviewFrame) {
            for value in GlassCalloutView.ArrowDirection.allValues where value != position {
                let newFrame = computeFrame(arrowPosition: value,
                                            refViewFrame: refViewFrame,
                                            superviewFrame: superviewFrame)
                if isFrameValid(newFrame, forRefViewFrame: refViewFrame, withinSuperviewFrame: superviewFrame) {

                    frame = newFrame
                    position = value
                    preferences.drawing.arrowPosition = value
                    break
                }
            }
        }

        var arrowTipXOrigin: CGFloat

        switch position {
        case .any, .top:
            if frame.width < refViewFrame.width {
                arrowTipXOrigin = tipViewSize.width / 2
            } else {
                arrowTipXOrigin = abs(frame.x - refViewFrame.x) + refViewFrame.width / 2
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: 0)
        case .topLeft:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = GlassSpacing.small + GlassSpacing.xSmall
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: 0)
        case .topRight:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = tipViewSize.width - (GlassSpacing.small + GlassSpacing.xSmall)
            }
            arrowTip = CGPoint(x: arrowTipXOrigin, y: 0)
        case .bottom:
            if frame.width < refViewFrame.width {
                arrowTipXOrigin = tipViewSize.width / 2
            } else {
                arrowTipXOrigin = abs(frame.x - refViewFrame.x) + refViewFrame.width / 2
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: tipViewSize.height )
        case .bottomLeft:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = GlassSpacing.small + GlassSpacing.xSmall
            }

            var y: CGFloat = 0
            if position == .bottomLeft || position == .bottomRight {
                y = tipViewSize.height
            } else {
                y = 0
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: y)
        case .bottomRight:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = tipViewSize.width - (GlassSpacing.small + GlassSpacing.xSmall)
            }

            var y: CGFloat = 0
            if position == .bottomLeft || position == .bottomRight {
                y = tipViewSize.height
            } else {
                y = 0
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: y)
        case .left:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = abs(frame.y - refViewFrame.y) + refViewFrame.height / 2
            }

            arrowTip = CGPoint(x: 0, y: arrowTipXOrigin)
        case.right:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = tipViewSize.height / 2
            } else {
                arrowTipXOrigin = abs(frame.y - refViewFrame.y) + refViewFrame.height / 2
            }

            arrowTip = CGPoint(x: tipViewSize.width, y: arrowTipXOrigin)
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = getContentRect(from: getBubbleFrame())

        self.frame = frame
    }

    fileprivate func addInteractionViewIfNeeded(with superView: UIView) {
        //This is special case when the superview doesn't have enough space to display callout,
        //and callout is dispalyed out of the superview frame, we need handle user actions
        interactionView = InteractionView(monitorView: self,
                                          parentView: UIApplication.shared.windows.first!,
                                          referenceView: superView)
    }

    fileprivate func removeInteractionViewIfAdded() {
        //Remove the interactionView if added since the callout is removed
        if let interactionView = interactionView {
            interactionView.removeFromSuperview()
            self.interactionView = nil
        }
    }

    private func visibleFrame(for view: UIView) -> CGRect {
        let superviewFrame: CGRect
        if let scrollview = view as? UIScrollView {
          superviewFrame = CGRect(origin: scrollview.frame.origin, size: scrollview.contentSize)
        } else {
          superviewFrame = view.frame
        }
        return superviewFrame
    }

    // MARK: Callbacks

    @objc func handleTapOnView() {
        self.delegate?.didTapOnCalloutView(self)
    }

    // MARK: Drawing

    fileprivate func drawBubble(_ bubbleFrame: CGRect, arrowPosition: GlassCalloutView.ArrowDirection, context: CGContext) {

        let arrowWidth = preferences.drawing.arrowWidth
        let arrowHeight = preferences.drawing.arrowHeight
        let cornerRadius = preferences.drawing.cornerRadius

        let contourPath = CGMutablePath()

        contourPath.move(to: CGPoint(x: arrowTip.x, y: arrowTip.y))

        switch arrowPosition {
        case .bottom, .top, .any:

            contourPath.addLine(to: CGPoint(x: arrowTip.x - arrowWidth / 2,
                                            y: arrowTip.y + (arrowPosition == .bottom ? -1 : 1) * arrowHeight))
            if arrowPosition == .bottom {
                drawBubbleBottomShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            } else {
                drawBubbleTopShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            contourPath.addLine(to: CGPoint(x: arrowTip.x + arrowWidth / 2,
                                            y: arrowTip.y + (arrowPosition == .bottom ? -1 : 1) * arrowHeight))

        case .bottomLeft, .bottomRight, .topLeft, .topRight:
            var y : CGFloat = 0
            if arrowPosition == .bottomLeft || arrowPosition == .bottomRight {
                y = arrowTip.y + arrowHeight * -1
            } else {
                y = arrowTip.y + arrowHeight
            }
            contourPath.addLine(to: CGPoint(x: arrowTip.x - arrowWidth / 2,
                                            y: y))
            if arrowPosition == .bottomLeft || arrowPosition == .bottomRight {
                drawBubbleBottomShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            } else {
                drawBubbleTopShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            contourPath.addLine(to: CGPoint(x: arrowTip.x + arrowWidth / 2,
                                            y: y))
        case .right, .left:

            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight,
                                            y: arrowTip.y - arrowWidth / 2))

            if arrowPosition == .right {
                drawBubbleRightShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            } else {
                drawBubbleLeftShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }

            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight,
                                            y: arrowTip.y + arrowWidth / 2))
        }

        contourPath.closeSubpath()
        context.addPath(contourPath)
        context.clip()

        paintBubble(context)
    }

    fileprivate func drawBubbleBottomShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {

        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x, y: frame.y),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    radius: cornerRadius)
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

    fileprivate func drawBubbleRightShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {

        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    tangent2End: CGPoint(x: frame.x, y: frame.y),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y),
                    tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    radius: cornerRadius)

    }

    fileprivate func drawBubbleLeftShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {

        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y),
                    tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height),
                    tangent2End: CGPoint(x: frame.x, y: frame.y),
                    radius: cornerRadius)
    }

    fileprivate func paintBubble(_ context: CGContext) {
        context.setFillColor(preferences.drawing.backgroundColor.cgColor)
        context.fill(bounds)
    }

    override open func draw(_ rect: CGRect) {

        let bubbleFrame = getBubbleFrame()

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        drawBubble(bubbleFrame, arrowPosition: preferences.drawing.arrowPosition, context: context)

        addSubview(contentView)

        context.restoreGState()
    }

    private func getBubbleFrame() -> CGRect {
        let arrowPosition = preferences.drawing.arrowPosition
        let bubbleWidth: CGFloat
        let bubbleHeight: CGFloat
        let bubbleXOrigin: CGFloat
        let bubbleYOrigin: CGFloat
        switch arrowPosition {
        case .bottom, .top, .any:

            bubbleWidth = tipViewSize.width
            bubbleHeight = tipViewSize.height - preferences.drawing.arrowHeight

            bubbleXOrigin = 0
            bubbleYOrigin = arrowPosition == .bottom ? 0 : preferences.drawing.arrowHeight

        case .bottomLeft, .bottomRight, .topLeft, .topRight:
            bubbleWidth = tipViewSize.width
            bubbleHeight = tipViewSize.height - preferences.drawing.arrowHeight

            bubbleXOrigin = 0
            if arrowPosition == .bottomLeft || arrowPosition == .bottomRight {
                bubbleYOrigin = 0
            } else {
                bubbleYOrigin = preferences.drawing.arrowHeight
            }
        case .left, .right:

            bubbleWidth = tipViewSize.width - preferences.drawing.arrowHeight
            bubbleHeight = tipViewSize.height

            bubbleXOrigin = arrowPosition == .right ? 0 : preferences.drawing.arrowHeight
            bubbleYOrigin = 0

        }
        return CGRect(x: bubbleXOrigin, y: bubbleYOrigin, width: bubbleWidth, height: bubbleHeight)
    }

    private func getContentRect(from bubbleFrame: CGRect) -> CGRect {
        return CGRect(x: bubbleFrame.origin.x + (bubbleFrame.size.width - contentView.frame.width) / 2,
                      y: bubbleFrame.origin.y + (bubbleFrame.size.height - contentView.frame.height) / 2,
                      width: contentView.frame.width,
                      height: contentView.frame.height)
    }

    func handleTapEvent(at point: CGPoint) {
        delegate?.handleTapEvent(at: self.convert(point, from: superview))
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

    fileprivate var center: CGPoint {
        return CGPoint(x: self.x + self.width / 2, y: self.y + self.height / 2)
    }
}
// swiftlint:enable line_length

// MARK: - TestHooks

#if DEBUG
extension GlassCalloutTipView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassCalloutTipView

        var delegate: GlassCalloutTipViewDelegate? {
            target.delegate
        }

        fileprivate init(target: GlassCalloutTipView) {
            self.target = target
        }

        func callHandleTapOnView() {
            target.handleTapOnView()
        }
    }
}
#endif

///This calss is mainly responsible for handling user interactions on monitorView with respect to parentView
/// where both are in same window with diffrent subviews's hirarchy
private class InteractionView: BaseView {
    let monitorView: GlassCalloutTipView
    let parentView: UIView
    let referenceView: UIView

    init(monitorView: GlassCalloutTipView, parentView: UIView, referenceView: UIView) {
        self.monitorView = monitorView
        self.parentView = parentView
        self.referenceView = referenceView
        super.init(frame: .zero)
        setup()
        setConstraints()
    }

    private func setup() {
        layer.masksToBounds = true

        parentView.addAutoLayoutSubview(self)
    }

    /// Setting up constraints for the layout of the view
    private func setConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            self.constraints(pinningTo: parentView)
        )
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let location = parentView.convert(point, to: referenceView)
        return monitorView.frame.contains(location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: referenceView)
        if monitorView.frame.contains(location) {
            monitorView.handleTapEvent(at: location)
        }
    }
}
