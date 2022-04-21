//
//  GlassCard.swift
//  GlassUI
//
//  Created by Jose Garzadiaz on 4/22/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A vertical stack view with a custom shadowed background layer that creates the appearance of a card.
///
/// [Zeplin reference](https://zpl.io/VqJxqMG)
open class GlassCard: ElevatingView {

    /// The style of the card, defined by the width of the card relative to the screen.
    public enum Style: Int {
        /// Style for a card that occupies the full screen width.
        case full = 1
        /// Style for a card that occupies half of the screen width.
        case half
        /// Style for a card that occupies a third of the screen width.
        case third
        /// Style for a card that occupies a quarter of the screen width.
        case quarter

        var cornerRadius: CGFloat {
            switch self {
            case .full, .half, .third:
                return GlassSpacing.xSmall
            case .quarter:
                return GlassSpacing.xxSmall
            }
        }

        var inset: CGFloat {
            switch self {
            case .full:
                return GlassSpacing.small
            case .half:
                return GlassSpacing.xSmall
            case .third, .quarter:
                return GlassSpacing.xxSmall
            }
        }
    }

    /// An object describing a card's appearance, including optional overrides for corner radius and inset.
    public struct Model {
        /// The style of the card.
        public var style: Style
        /// The custom corner radius of the card. If `nil`, the corner radius defined by `style` will be used.
        public var customCornerRadius: CGFloat?
        /// The custom inset of the card. If `nil`, the inset defined by `style` will be used.
        public var customInset: CGFloat?
        /// The model for the header of the card.
        public var headerModel: HeaderModel
        /// The elevationLevel of the card
        public var elevationLevel: LDElevationLevel
        /// Custom insets for edge
        public var customInsetEdge: NSDirectionalEdgeInsets?

        var cornerRadius: CGFloat {
            customCornerRadius ?? style.cornerRadius
        }

        var inset: NSDirectionalEdgeInsets {
            if let customInset = customInset {
                return NSDirectionalEdgeInsets(uniformInset: customInset)
            } else if let customInsetEdge = customInsetEdge {
                return customInsetEdge
            } else {
                return NSDirectionalEdgeInsets(uniformInset: style.inset)
            }
        }

        public init(style: Style,
                    elevationLevel: LDElevationLevel = .one,
                    customCornerRadius: CGFloat? = nil,
                    customInset: CGFloat? = nil,
                    headerModel: HeaderModel = .init(),
                    customInsetEdge: NSDirectionalEdgeInsets? = nil) {
            self.style = style
            self.elevationLevel = elevationLevel
            self.customCornerRadius = customCornerRadius
            self.customInset = customInset
            self.headerModel = headerModel
            self.customInsetEdge = customInsetEdge
        }
    }

    public var model: Model = .init(style: .full) {
        didSet { applyModel() }
    }

    private var headerView: GlassCardHeader = .init()
    private let stackView: UIStackView = .init(axis: .vertical)

    /// Creates an instance of `GlassCard` with a default style based on its size.
    /// - Parameter model: An object describing the desired style of the card.
    public init(model: Model) {
        super.init(elevationLevel: .three, frame: .zero)
        self.model = model
        applyModel()
    }

    open override func constructView() {
        super.constructView()
        stackView.isLayoutMarginsRelativeArrangement = true
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = GlassColor.gray00.uiColor
    }

    open override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(headerView)
        addAutoLayoutSubview(stackView)
    }

    open override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            headerView.constraints(pinningTo: self, edges: [.top, .leading, .trailing],
                                   priority: .requiredCompliant),
            stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.constraints(pinningTo: self, edges: [.bottom, .leading, .trailing],
                                  priority: .required)
        )
    }

    open func applyModel() {
        headerView.model = model.headerModel
        elevationLevel = model.elevationLevel
        layer.cornerRadius = model.cornerRadius
        stackView.directionalLayoutMargins = model.inset
        setNeedsLayout()
    }
}

// MARK: UIStackView proxy methods

public extension GlassCard {

    var arrangedSubviews: [UIView] { stackView.arrangedSubviews }

    func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func addArrangedSubviews(_ views: [UIView]) {
        stackView.addArrangedSubviews(views)
    }

    func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        stackView.insertArrangedSubview(view, at: stackIndex)
    }

    /// **Proxy UIStackView method to remove the arranged subview**
    ///
    /// Removes a subview from the list of arranged subviews without removing it as
    /// a subview of the receiver.
    /// To remove the view as a subview, send it -removeFromSuperview as usual;
    /// the relevant UIStackView will remove it from its arrangedSubviews list
    /// automatically.
    /// - Parameters:
    ///   - view: Subview to be removed
    func removeArrangedSubview(_ view: UIView) {
        stackView.removeArrangedSubview(view)
    }

    var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }

    func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        stackView.setCustomSpacing(spacing, after: arrangedSubview)
    }

    var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
}
