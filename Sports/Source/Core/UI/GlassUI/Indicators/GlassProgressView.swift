//
//  GlassProgressView.swift
//  GlassUI
//
//  Created by Stephen Downs on 2020-05-07.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Determinate bar indicator with optional tick marks and labels.
///
/// Has a segmented or linear presentation style.
/// Segmented style depicts tickmarks at equal intervals with optional text labels.
///
/// Tick marks are determined by the `tickMarkTitles` array.
///
/// See also: GlassBarIndicator - same as GlassProgressView but without text labels.
public class GlassProgressView: BaseView {

    private static let voiceOverFormatString = "progressView.generalStepVoiceOver".localize()

    // MARK: - Properties

    /// Progress minimum value.
    public static let minProgress = GlassBarIndicator.minProgress

    /// Progress maximum value.
    public static let maxProgress = GlassBarIndicator.maxProgress

    /// Maximum possible number of tick marks.
    /// The initial tick mark at position 0 is not included.
    public static let maxTickMarkCount = GlassBarIndicator.maxTickMarkCount

    /// Index of the currently highlighted label in the group.
    /// Set to nil to un-highlight all labels.
    public var highlightedLabelIndex: Int? {
        get {
            tickMarkLabelsView.highlightedLabelIndex
        }
        set {
            tickMarkLabelsView.highlightedLabelIndex = newValue
        }
    }

    /// When true, the voiceover text will be using the following text format: "Current step %1$d of %2$d: %3$@"
    /// example: "Current step 3 of 3: Redeem""
    public var announceProgressOnVoiceOver: Bool = false {
        didSet {
            updateView()
        }
    }

    /// Progress ranged from 0.0 to 1.0.
    @GlassBarIndicator.Clamped(to: GlassProgressView.minProgress...GlassProgressView.maxProgress)
    public var progress: Float = GlassProgressView.minProgress {
        didSet {
            indicatorView.progress = progress
            updateAccessibilityValue()
        }
    }

    /// Custom filled progress bar color.
    public var progressColor: GlassColor? {
        get {
            indicatorView.progressColor
        }
        set {
            indicatorView.progressColor = newValue
        }
    }

    /// Show only the highlighted label.
    public var showHighlightedLabelOnly: Bool {
        get {
            tickMarkLabelsView.showHighlightedLabelOnly
        }
        set {
            tickMarkLabelsView.showHighlightedLabelOnly = newValue
        }
    }

    /// Label text color.
    public var textColor: GlassColor? {
        get {
            tickMarkLabelsView.textColor
        }
        set {
            tickMarkLabelsView.textColor = newValue
        }
    }

    /// Highlighted label text color.
    public var textHighlightedColor: GlassColor? {
        get {
            tickMarkLabelsView.textHighlightedColor
        }
        set {
            tickMarkLabelsView.textHighlightedColor = newValue
        }
    }

    /// The label number of lines. See UILabel documentation for details.
    ///
    /// Defaults to 1 as defined by UIKit.
    public var numberOfLines: Int {
        get {
            tickMarkLabelsView.numberOfLines
        }
        set {
            tickMarkLabelsView.numberOfLines = newValue
        }
    }

    /// Number of tick marks.
    public var tickMarkCount: Int {
        tickMarkTitles.count > 1 ?
            min(tickMarkTitles.count - 1, GlassProgressView.maxTickMarkCount) :
            tickMarkTitles.count
    }

    /// Tick mark titles.
    public var tickMarkTitles = [String]() {
        didSet {
            updateView()
        }
    }

    /// Custom progress bar track color.
    public var trackColor: GlassColor? {
        get {
            indicatorView.trackColor
        }
        set {
            indicatorView.trackColor = newValue
        }
    }

    /// Show Position Ring.
    public var showCurrentPositionRing: Bool {
       get {
           indicatorView.showCurrentPositionRing
       }
       set {
           indicatorView.showCurrentPositionRing = newValue
       }
   }

    private var contentView: UIStackView!
    private var indicatorView: GlassBarIndicator!
    private var tickMarkLabelsView: GlassBarLabelGroup!

    // MARK: - Construction

    public override func constructView() {
        isOpaque = false

        contentView = UIStackView()
        contentView.alignment = .center
        contentView.axis = .vertical
        contentView.spacing = GlassSpacing.xSmall

        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .summaryElement
        if contentView.accessibilityLabel == nil {
            contentView.accessibilityLabel = "progress".localize()
        }

        addSubview(contentView)
    }

    public override func constructSubviewHierarchy() {
        indicatorView = GlassBarIndicator()

        tickMarkLabelsView = GlassBarLabelGroup()

        indicatorView.isAccessibilityElement = false
        tickMarkLabelsView.isAccessibilityElement = false

        contentView.addArrangedSubview(indicatorView)
        contentView.addArrangedSubview(tickMarkLabelsView)
    }

    public override func constructSubviewLayoutConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate(
            contentView.constraints(pinningTo: self),
            indicatorView.constraints(pinningTo: contentView, edges: .horizontal),
            tickMarkLabelsView.constraints(pinningTo: contentView, edges: .horizontal)
        )
    }

    // MARK: - Methods

    private func updateAccessibilityValue() {
        if tickMarkCount == 0 {
            contentView.accessibilityValue = "\(Int(progress * 100))%"
        } else {
            let segmentLength = GlassProgressView.maxProgress / Float(tickMarkCount)
            let progressLabelIndex = Int(progress / segmentLength).clamped(to: 0...tickMarkCount)
            if announceProgressOnVoiceOver {
                contentView.accessibilityValue = currentStepAnnouncement(currentStep: progressLabelIndex + 1 ,
                                                                         stepCounts: tickMarkCount + 1,
                                                                         stepLabel: tickMarkTitles[progressLabelIndex])
            } else {
                contentView.accessibilityValue = tickMarkTitles[progressLabelIndex]
            }

            if contentView.accessibilityValue == "" {
                contentView.accessibilityValue = "\(Int(progress * 100))%"
            }
        }
    }

    private func updateView() {
        if tickMarkTitles.count > GlassBarIndicator.maxTickMarkCount {
            tickMarkLabelsView.labelText = Array(tickMarkTitles[0...GlassBarIndicator.maxTickMarkCount])
        } else {
            tickMarkLabelsView.labelText = tickMarkTitles
        }
        indicatorView.tickMarkCount = tickMarkCount

        updateAccessibilityValue()
        setNeedsLayout()
    }

    private func currentStepAnnouncement(currentStep: Int, stepCounts: Int, stepLabel: String) -> String {
        return String(format: GlassProgressView.voiceOverFormatString,
                      currentStep,
                      stepCounts,
                      stepLabel)
    }
}

#if DEBUG
extension GlassProgressView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassProgressView

        fileprivate init(target: GlassProgressView) {
            self.target = target
        }

        var indicator: GlassBarIndicator { target.indicatorView }
        var accessibilityElement: UIView { target.contentView as UIView }
        var labels: [GlassLabel] { target.tickMarkLabelsView.testHooks.labels }
    }
}
#endif
