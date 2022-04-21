//
//  GlassBadge.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/15/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A view with a colored background, a label, and an optional left-anchored icon
/// # Discussion
/// [Zeplin Reference](https://zpl.io/2yZJDZJ)
///
/// # Example
/// ```swift
/// let badge = GlassBadge(text: "Tomorrow", style: .primary, icon: .clock)
/// ```
public final class GlassBadge: BaseView {

    public var model: Model {
        didSet { applyModel() }
    }

    internal let iconView: UIImageView
    internal let label: UILabel

    private let mainStackView: UIStackView
    private var mainStackViewLeadingConstraint: NSLayoutConstraint?
    private let backgroundView: UIView

    public init(model: Model = Model()) {
        self.model = model

        label = UILabel()
        label.font = GlassFont.captionRegular().uiFont
        iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        mainStackView = UIStackView(axis: .horizontal, alignment: .leading)
        backgroundView = UIView()

        super.init(frame: .zero)

        applyModel()
    }

    public override func constructView() {
        super.constructView()

        backgroundView.layer.cornerRadius = 2.0
        backgroundView.layer.borderWidth = 1.0
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        mainStackView.addArrangedSubview(iconView)
        mainStackView.addArrangedSubview(label)

        backgroundView.addAutoLayoutSubview(mainStackView)
        addAutoLayoutSubview(backgroundView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        label.setContentHuggingPriority(UILayoutPriority.defaultLow.decreased, for: .horizontal)
        mainStackView.spacing = GlassSpacing.xxSmall
        mainStackViewLeadingConstraint = mainStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor,
                                                                                constant: model.horizontalPadding)
        NSLayoutConstraint.activate(
            mainStackViewLeadingConstraint,
            mainStackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: GlassSpacing.xxSmall),
            mainStackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),

            iconView.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            backgroundView.constraints(pinningTo: self, edges: .all)
        )
    }

    private func applyModel() {
        iconView.isHidden = model.icon == nil
        iconView.image = model.icon?.image(.size12).withRenderingMode(model.iconRenderingMode)
        iconView.tintColor = model.textColor.uiColor
        label.text = model.text
        label.textColor = model.textColor.uiColor
        accessibilityLabel = model.text
        backgroundView.layer.borderColor = model.borderColor.cgColor
        backgroundView.backgroundColor = model.backgroundColor.uiColor
        updateLeadingConstraintIfRequired()
    }

    private func updateLeadingConstraintIfRequired() {
        guard let constraint = mainStackViewLeadingConstraint,
              constraint.constant != model.horizontalPadding else { return }

        mainStackViewLeadingConstraint?.constant = model.horizontalPadding
    }
}

#if DEBUG
import SwiftUI

struct GlassBadgeView: UIViewRepresentable {

    let model: GlassBadge.Model

    func makeUIView(context: Context) -> UIView {
        GlassBadge(model: model)
    }

    func updateUIView(_ view: UIView, context: Context) {

    }
}

struct GlassBadgeViewPreview: PreviewProvider {

    static let badges: [GlassBadge.Model] = [
        .init(text: "Today", badgeColor: .green10, icon: .clock, style: .fill(textColor: .green100)),
        .init(text: "Tomorrow", badgeColor: .blue10, icon: .clock, style: .fill(textColor: .blue100)),
        .init(text: "2 Days", badgeColor: .gray10, icon: .clock, style: .fill(textColor: .gray100)),
        .init(text: "PG-13", badgeColor: .gray100, icon: .clock, style: .outline)
    ]

    static var previews: some View {
        List(Self.badges, id: \.text) { item in
            GlassBadgeView(model: item)
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
        .padding([.leading, .top], GlassSpacing.medium)
        .previewDevice("iPhone X")
    }
}
#endif
