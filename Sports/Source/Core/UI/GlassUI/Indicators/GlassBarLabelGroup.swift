//
//  GlassBarLabelGroup.swift
//  GlassUI
//
//  Created by Stephen Downs on 2020-05-13.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Horizontally grouped label display.
///
/// Intended for alignment with segmented progress indicator tick marks.
public final class GlassBarLabelGroup: BaseView {

    // Default label text colors associated with label state.
    enum TextColor {
        public static let normal = GlassColor.gray50
        public static let highlighted = GlassColor.gray140
    }

    // MARK: - Properties

    /// Index of the currently highlighted label in the group.
    /// Set to nil to un-highlight all labels.
    public var highlightedLabelIndex: Int? {
        get { labels.firstIndex(where: { $0.isHighlighted }) }
        set {
            selectedHighlightedLabelIndex = newValue
            updateLabelAppearance()
        }
    }

    /// Array of strings representing labels.
    public var labelText = [String]() {
        didSet { constructLabels() }
    }

    /// Show only the highlighted label.
    public var showHighlightedLabelOnly: Bool = false {
        didSet {
            if isShowingMultipleLabels {
                constructLabels()
            } else {
                updateLabelAppearance()
            }
        }
    }

    /// Label text color.
    public var textColor: GlassColor? {
        didSet { applyStyle() }
    }

    /// Highlighted label text color.
    public var textHighlightedColor: GlassColor? {
        didSet { applyStyle() }
    }

    /// The label number of lines. See UILabel documentation for details.
    ///
    /// Defaults to 1 as defined by UIKit.
    public var numberOfLines: Int = 1 {
        didSet { updateLabelLineNumbers() }
    }

    // Indicates that multiple labels are visible at once.
    private var isShowingMultipleLabels: Bool {
        labelText.count > 2 && !(showHighlightedLabelOnly && highlightedLabelIndex != nil)
    }

    private var labelStackView: UIStackView!
    private var labels = [GlassLabel]()
    private var selectedHighlightedLabelIndex: Int?

    // MARK: - Construction

    override public func constructView() {
        labelStackView = UIStackView()
        labelStackView.alignment = .firstBaseline
        labelStackView.axis = .horizontal
        labelStackView.distribution = .equalCentering

        addSubview(labelStackView)
    }

    override public func constructSubviewLayoutConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let constraints: [NSLayoutConstraint] = [
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func constructLabels() {
        labelStackView.removeAllArrangedSubviews()
        labelStackView.subviews.forEach { $0.removeFromSuperview() }
        labels = []

        for text in labelText {
            let label = GlassLabel(style: .captionRegular)
            label.text = text
            label.textAlignment = .center
            labelStackView.addArrangedSubview(label)
            labels.append(label)
        }
        labels.last?.textAlignment = .right
        if labelText.count > 1 {
            labels.first?.textAlignment = .left
        }

        // Label centering on inner labels can be thrown off by different instrinsic widths of stack elements.
        // Layout works well if first and last labels have minimal instrinsic widths.
        if isShowingMultipleLabels {
            // Replace existing first and last labels with explicitly placed versions attached on top of stack view.
            let firstLabel = GlassLabel(style: .captionRegular)
            firstLabel.textColor = textColor?.uiColor
            firstLabel.text = labelText.first
            firstLabel.textAlignment = .left
            labelStackView.addAutoLayoutSubview(firstLabel)

            let lastLabel = GlassLabel(style: .captionRegular)
            lastLabel.textColor = textColor?.uiColor
            lastLabel.text = labelText.last
            lastLabel.textAlignment = .right
            labelStackView.addAutoLayoutSubview(lastLabel)

            let constraints: [NSLayoutConstraint] = [
                firstLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
                lastLabel.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
                firstLabel.firstBaselineAnchor.constraint(equalTo: labelStackView.firstBaselineAnchor),
                lastLabel.firstBaselineAnchor.constraint(equalTo: labelStackView.firstBaselineAnchor)
            ]
            NSLayoutConstraint.activate(constraints)

            // Effectively hide first and last labels in stack view, keeping them only as layout bookends.
            labels.first?.text = ""
            labels.first?.isAccessibilityElement = false
            labels.last?.text = ""
            labels.last?.isAccessibilityElement = false

            labels[0] = firstLabel
            labels[labels.count-1] = lastLabel
        }

        labelStackView.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        updateLabelLineNumbers()
        applyStyle()
        updateLabelAppearance()
    }

    // MARK: - Methods

    private func updateLabelLineNumbers() {
        let numberOfLines = self.numberOfLines
        for label in labels {
            label.numberOfLines = numberOfLines
        }
    }

    private func applyStyle() {
        let textColor = self.textColor ?? TextColor.normal
        let highlightedColor = self.textHighlightedColor ?? TextColor.highlighted

        for label in labels {
            label.textColor = textColor.uiColor
            label.highlightedTextColor = highlightedColor.uiColor
        }
    }

    private func updateLabelAppearance() {
        labels.forEach { $0.isHighlighted = false }

        var isALabelHighlighted = false
        if let highlightedIndex = selectedHighlightedLabelIndex,
            highlightedIndex > -1,
            highlightedIndex < labels.count {
            isALabelHighlighted = true
            labels[highlightedIndex].isHighlighted = true
        }

        if showHighlightedLabelOnly && isALabelHighlighted {
            for (index, label) in labels.enumerated() {
                let visible = label.isHighlighted
                label.text = visible ? labelText[index] : nil
                label.isAccessibilityElement = visible
            }
        } else {
            for (index, label) in labels.enumerated() {
                label.text = labelText[index]
                label.isAccessibilityElement = true
            }
        }
    }
}

#if DEBUG
extension GlassBarLabelGroup {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassBarLabelGroup

        fileprivate init(target: GlassBarLabelGroup) {
            self.target = target
        }

        var labels: [GlassLabel] { return target.labels }
    }
}
#endif
