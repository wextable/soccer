//
//  GlassCardHeader.swift
//  GlassUI
//
//  Created by Brandon Larkin on 6/12/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension GlassCard.Model {

    /// A model specifying the contents of a GlassCard's header view.
    struct HeaderModel: Equatable {
        /// The text to display in the header.
        public var text: String?
        /// The color of the header bar, defaults to blue10.
        public var backgroundColor: UIColor = GlassColor.blue10.uiColor
        /// Custom view to display.
        public var headerView: UIView?

        public init() {
            //no-op
        }

        public init(text: String? = nil,
                    backgroundColor: UIColor = GlassColor.blue10.uiColor) {
            self.text = text
            self.backgroundColor = backgroundColor
        }

        public init(backgroundColor: UIColor = GlassColor.blue10.uiColor,
                    headerView: UIView? = nil) {
            self.backgroundColor = backgroundColor
            self.headerView = headerView
        }
    }
}

internal final class GlassCardHeader: BaseView {

    var model: GlassCard.Model.HeaderModel {
        didSet { applyModel() }
    }

    private var headerHiddenConstraint: NSLayoutConstraint!
    private let titleLabel: GlassLabel
    private let headerViewContainer: UIView

    init(model: GlassCard.Model.HeaderModel = .init()) {
        self.model = model
        titleLabel = GlassLabel(style: .subheading1)
        headerViewContainer = UIView()

        super.init(frame: .zero)

        applyModel()
    }

    override func constructView() {
        super.constructView()

        titleLabel.numberOfLines = 0
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(titleLabel)
        addSubview(headerViewContainer)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        headerHiddenConstraint = heightAnchor.constraint(equalToConstant: .zero)
        headerViewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.constraints(pinningTo: self,
                               edges: [.leading, .top, .trailing],
                               insets: .init(GlassSpacing.small)).activate()
        titleLabel.constraints(pinningTo: self,
                               edges: [.bottom],
                               insets: .init(GlassSpacing.small),
                               priority: .requiredCompliant).activate()
    }

    private func applyModel() {
        backgroundColor = model.backgroundColor
        if let headerView = model.headerView {
            titleLabel.text = nil
            titleLabel.isAccessibilityElement = false
            headerViewContainer.subviews.forEach { $0.removeFromSuperview() }
            headerViewContainer.addAutoLayoutSubview(headerView)
            headerView.constraints(pinningTo: headerViewContainer).activate()
            headerHiddenConstraint.isActive = false
        } else {
            titleLabel.text = model.text
            titleLabel.isAccessibilityElement = model.text?.isEmpty ?? false
            headerViewContainer.subviews.forEach { $0.removeFromSuperview() }
            headerHiddenConstraint.isActive = model.text?.isEmpty ?? true
        }
    }
}
