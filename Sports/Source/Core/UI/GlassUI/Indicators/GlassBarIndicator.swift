//
//  GlassBarIndicator.swift
//  GlassUI
//
//  Created by Stephen Downs on 2020-05-11.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Determinate bar indicator with optional tick marks.
public class GlassBarIndicator: BaseView {

    // MARK: - Properties

    /// Progress minimum value.
    public static let minProgress: Float = .zero

    /// Progress maximum value.
    public static let maxProgress: Float = 1.0

    /// Minimum possible number of tick marks.
    public static let minTickMarkCount = 0

    /// Maximum possible number of tick marks.
    /// The initial tick mark at position 0 is not included.
    public static let maxTickMarkCount = 3

    /// Default filled progress bar color.
    public static let progressColorDefault = GlassColor.blue100

    /// Default progress bar track color.
    public static let trackColorDefault = GlassColor.gray30

    /// The natural size for the receiving view, considering only properties of the view itself.
    override public var intrinsicContentSize: CGSize {
        let intrinsicWidth: CGFloat = tickMarkCount > 0 ?
            indicatorHeight * CGFloat(tickMarkCount) * 4 : super.intrinsicContentSize.width
        return CGSize(width: intrinsicWidth, height: indicatorHeight + 10)
    }

    /// Progress ranged from 0.0 to 1.0.
    @Clamped(to: GlassBarIndicator.minProgress...GlassBarIndicator.maxProgress)
    public var progress: Float = .zero {
        didSet {
            updateAccessibilityValue()
            setNeedsDisplay()
        }
    }

    /// Custom filled progress bar color.
    public var progressColor: GlassColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Number of tick marks.
    /// The initial tick mark at position 0 is not included in this total.
    @Clamped(to: GlassBarIndicator.minTickMarkCount...GlassBarIndicator.maxTickMarkCount)
    public var tickMarkCount: Int = GlassBarIndicator.minTickMarkCount {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /// Custom progress bar track color.
    public var trackColor: GlassColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    private var leftOffset: CGFloat = 0
    public var showCurrentPositionRing: Bool = false {
        didSet {
            leftOffset = self.showCurrentPositionRing ? 5 : 0
            setNeedsDisplay()
        }
    }

    private let indicatorHeight: CGFloat = 9
    private let lineHeight: CGFloat = 3

    // MARK: - Construction

    public override func constructView() {
        isOpaque = false

        self.isAccessibilityElement = true
        self.accessibilityTraits = .summaryElement
        if self.accessibilityLabel == nil {
            self.accessibilityLabel = "progress".localize()
        }
        self.accessibilityValue = "\(Int(progress * 100))%"
        setNeedsDisplay()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    // MARK: - Drawing

    override public func draw(_ rect: CGRect) {
        drawIndicator(rect)
    }

    // Draw entire indicator.
    private func drawIndicator(_ rect: CGRect) {
        let progressColor = (self.progressColor ?? GlassBarIndicator.progressColorDefault).uiColor
        let progressWidth = (rect.width - (2 * leftOffset)) * CGFloat(progress)
        let trackColor = (self.trackColor ?? GlassBarIndicator.trackColorDefault).uiColor
        var currentTick = CGRect(x: rect.minX + leftOffset,
                                 y: rect.minY,
                                 width: indicatorHeight,
                                 height: indicatorHeight)

        // Draw bar track.
        drawBar(CGRect(x: rect.minX + (2 * leftOffset),
                       y: rect.minY + leftOffset,
                       width: rect.width - (2 * leftOffset),
                       height: rect.height),
                color: trackColor)

        if tickMarkCount > 0 {
            // Bar is segmented with tick marks.
            // A first tick mark is placed at position 0.
            drawTickMark(
                CGRect(x: rect.minX + leftOffset, y: rect.minY, width: indicatorHeight, height: indicatorHeight),
                color: progressColor)

            // Middle tick marks.
            let progressPosition = rect.width * CGFloat(progress)
            var tickMarkColor: UIColor
            if tickMarkCount > 1 {
                let segmentLength = rect.width / CGFloat(tickMarkCount)
                let tickMarkOffsetX = indicatorHeight / 2
                for tickMarkPosition in stride(from: segmentLength, to: rect.width, by: segmentLength) {
                    tickMarkColor = progressPosition >= tickMarkPosition ? progressColor : trackColor
                    drawTickMark(
                        CGRect(x: tickMarkPosition - tickMarkOffsetX,
                               y: rect.minY,
                               width: indicatorHeight,
                               height: indicatorHeight),
                        color: tickMarkColor)
                    if showCurrentPositionRing &&
                        progressPosition > tickMarkPosition &&
                        progressPosition < tickMarkPosition + segmentLength {

                        currentTick = CGRect(x: tickMarkPosition - tickMarkOffsetX,
                                        y: rect.minY,
                                        width: indicatorHeight,
                                        height: indicatorHeight)
                    }
                }
            }
            // Final tick mark.
            tickMarkColor = progress >= 1.0 ? progressColor : trackColor
            drawTickMark(
                CGRect(x: rect.width-indicatorHeight - leftOffset,
                       y: rect.minY,
                       width: indicatorHeight,
                       height: indicatorHeight),
                color: tickMarkColor)
            if showCurrentPositionRing &&
                progress >= 1.0 {
                currentTick = CGRect(x: rect.width-indicatorHeight - leftOffset,
                                y: rect.minY,
                                width: indicatorHeight,
                                height: indicatorHeight)
            }
            drawRing(currentTick,
                     color: progressColor)
        } else {
            // Bar has no tick marks, just a single tick mark graphic at the progress point.
            let knobX = max( min(progressWidth - indicatorHeight / 2, rect.width-indicatorHeight), 0)
            drawTickMark(
                CGRect(x: knobX, y: rect.minY, width: indicatorHeight, height: indicatorHeight),
                color: progressColor)
        }

        // Draw bar progress.
        drawBar(
            CGRect(x: rect.minX + (2 * leftOffset),
                   y: rect.minY + leftOffset,
                   width: progressWidth + leftOffset,
                   height: rect.height),
            color: progressColor)
    }

    // Draw a vertically centered line, bounded by rect.
    private func drawBar(_ rect: CGRect, color: UIColor) {
        let lineY = rect.minY + indicatorHeight/2
        let path = UIBezierPath()

        path.move(to: CGPoint(x: rect.minX, y: lineY))
        path.addLine(to: CGPoint(x: rect.width, y: lineY))
        path.close()

        color.setStroke()
        path.lineCapStyle = .round
        path.lineWidth = lineHeight
        path.stroke()
    }

    // Draw a circular tick mark.
    private func drawTickMark(_ rect: CGRect, color: UIColor) {
        let path = UIBezierPath(ovalIn: rect.offsetBy(dx: 0, dy: leftOffset))
        color.setFill()
        path.fill()
    }

    // Draw a ring
    private func drawRing(_ rect: CGRect, color: UIColor) {
        if !showCurrentPositionRing {
            return
        }
        self.clipsToBounds = false
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: -3, dy: -3).offsetBy(dx: 0, dy: leftOffset))
        color.setStroke()
        path.lineWidth = 2
        path.stroke()
    }

    // MARK: - Methods

    private func updateAccessibilityValue() {
        self.accessibilityValue = "\(Int(progress * 100))%"
    }

}

// MARK: - Property wrappers

extension GlassBarIndicator {

    @propertyWrapper
    public struct Clamped<T: Comparable> {
        private var range: ClosedRange<T>
        private var value: T
        public var wrappedValue: T {
            get { value }
            set { value = newValue.clamped(to: range) }
        }
        init(wrappedValue: T, to range: ClosedRange<T>) {
            self.range = range
            self.value = wrappedValue.clamped(to: range)
        }
    }

}
