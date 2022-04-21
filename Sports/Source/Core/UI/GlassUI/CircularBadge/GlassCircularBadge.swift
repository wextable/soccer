//
//  GlassCircularBadge.swift
//  GlassUI
//
//  Created by Antony Raphel on 06/10/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

/// A view with a colored background, and label.
/// # Discussion
/// [Zeplin Reference](https://zpl.io/V0NpokE)
///
/// # Example
/// ```swift
/// let badge = GlassCircularBadge(model: .init(text: "1",
///                                             badgeColor: .white,
///                                             outlineColor: .spark150,
///                                             backgroundColor: .spark100))
/// ```
public class GlassCircularBadge: BaseView {

    // MARK: - Model

    public struct Model {
        /// The text to display on the badge.
        public var text: String

        /// The color of the `text`.
        public var badgeColor: GlassColor

        /// The color of the border.
        public var outlineColor: GlassColor

        /// The color of the background.
        public var backgroundColor: GlassColor

        /// Creates and returns a `Model` with the provided parameters.
        public init(
            text: String = "",
            badgeColor: GlassColor = .black,
            outlineColor: GlassColor = .gray100,
            backgroundColor: GlassColor = .clear
        ) {
            self.text = text
            self.badgeColor = badgeColor
            self.outlineColor = outlineColor
            self.backgroundColor = backgroundColor
        }
    }

    // MARK: - Properties

    private struct Layout {
        // for the empty text container
        static let cornerRadius: CGFloat = 6.0
        // for the non-empty text container
        static let borerRadius: CGFloat = 8.0
        // badge with a 1.0 pt border
        static let borderWidth: CGFloat = 1.0
        // badge height/width with empty text
        static let emptySize: CGFloat = 12.0
        // badge height/width with non-empty text
        static let nonEmptySize: CGFloat = 16.0
    }

    /// The text to display on the badge.
    public var text: String = "" {
        didSet {
            model.text = text
            applyModel()
        }
    }

    public var model: Model {
        didSet {
            applyModel()
        }
    }

    internal let backgroundView = UIView()
    internal let label = GlassLabel(style: .captionBold)
    private var heightConstraint = NSLayoutConstraint()
    private var widthConstraint = NSLayoutConstraint()

    public init(model: Model = Model()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: - Construction

    public override func constructView() {
        super.constructView()

        label.textAlignment = .center
        backgroundView.layer.borderWidth = Layout.borderWidth
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        backgroundView.addAutoLayoutSubview(label)
        addAutoLayoutSubview(backgroundView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        label.setContentHuggingPriority(UILayoutPriority.defaultLow.decreased, for: .horizontal)
        widthConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.emptySize)
        heightConstraint = heightAnchor.constraint(equalToConstant: Layout.emptySize)

        NSLayoutConstraint.activate(
            label.constraints(
                pinningTo: backgroundView,
                insets: .init(horizontal: GlassSpacing.xxSmall),
                priority: .requiredCompliant
            ),

            backgroundView.constraints(pinningTo: self, edges: .all),
            widthConstraint,
            heightConstraint
        )
    }

    private func applyModel() {
        label.text = model.text
        label.textColor = model.badgeColor.uiColor
        backgroundView.layer.borderColor = model.outlineColor.uiColor.cgColor
        backgroundView.backgroundColor = model.backgroundColor.uiColor
        backgroundView.layer.cornerRadius = model.text.isEmpty ? Layout.cornerRadius : Layout.borerRadius
        widthConstraint.constant = model.text.isEmpty ? Layout.emptySize : Layout.nonEmptySize
        heightConstraint.constant = model.text.isEmpty ? Layout.emptySize : Layout.nonEmptySize

        layoutIfNeeded()
    }
}
