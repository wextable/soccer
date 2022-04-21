//
//  GlassTag.swift
//  GlassUI
//
//  Created by Amisha Chordia on 26/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

/// Tags are text content with an optional icon. There are three type of tags Primary, Secondary and Tertiary
/// These tags are supported in various shades - TagShade (red, spark, blue, green, purple, gray)
///
/// # Reference
/// [Zeplin Reference](https://zpl.io/bl34nE1)
///
/// # Example
/// ```swift
/// let tag = GlassTag(model: GlassTagModel(tagType: .secondary(shade: .purple), icon: GlassIcon.bag))
/// tag.tagText = "Your tag text"
/// ```
public class GlassTag: BaseView {

    public struct Defaults {
        public static let verticalSpacing = GlassSpacing.xxSmall
        public static let horizontalSpacing = GlassSpacing.xSmall
    }

    private struct Layout {
        static let cornerRadius: CGFloat = 2
        static let borderWidth: CGFloat = 1
    }

    private let label = GlassLabel(style: .captionRegular)
    private let iconView = UIImageView()
    private var horizontalSpacingConstraint: NSLayoutConstraint?
    private var labelLeadingConstraint: NSLayoutConstraint?
    private let verticalSpacing: CGFloat
    private let horizontalSpacing: CGFloat

    public var model: GlassTagModel {
        didSet {
            applyModel()
        }
    }

    public init(model: GlassTagModel,
                verticalSpacing: CGFloat = GlassTag.Defaults.verticalSpacing,
                horizontalSpacing : CGFloat = GlassTag.Defaults.horizontalSpacing) {
        self.model = model
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        super.init(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = Layout.borderWidth
        applyModel()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(label)
        addAutoLayoutSubview(iconView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        label.constraints(pinningTo: self,
                          edges: [.top, .bottom, .trailing],
                          insets: .init(vertical: verticalSpacing,
                                        trailing: horizontalSpacing)).activate()
        iconView.constraints(pinningTo: self,
                             edges: [.top, .bottom, .leading],
                             insets: .init(vertical: verticalSpacing,
                                        leading: horizontalSpacing)).activate()
        horizontalSpacingConstraint = iconView.trailingAnchor.constraint(equalTo: label.leadingAnchor)
        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                         constant: horizontalSpacing)
        updateIconViewVisibility()
        horizontalSpacingConstraint?.activate()
    }

    private func updateIconViewVisibility() {
        horizontalSpacingConstraint?.constant = model.icon != nil ? -GlassSpacing.xxSmall : 0
        if model.icon == nil {
            labelLeadingConstraint?.activate()
        } else {
            labelLeadingConstraint?.deactivate()
        }
    }

    private func applyModel() {
        updateIconViewVisibility()
        iconView.image = model.icon?.image(.size16).withRenderingMode(.alwaysTemplate)
        backgroundColor = model.tagType.backgroundColor.uiColor
        layer.borderColor = model.tagType.borderColor.uiColor.cgColor
        let contentForegroundColor = model.tagType.contentForegroundColor.uiColor
        iconView.tintColor = contentForegroundColor
        label.textColor = contentForegroundColor
        label.text = model.text
    }
}

#if DEBUG
extension GlassTag {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassTag

        fileprivate init(target: GlassTag) {
            self.target = target
        }

        var icon: GlassIcon? { return target.model.icon }
        var label: GlassLabel { return target.label }
        var iconView: UIImageView { return target.iconView }
        var horizontalSpacingConstraint: NSLayoutConstraint? { return target.horizontalSpacingConstraint }
        func updateIconViewVisibility() {
            target.updateIconViewVisibility()
        }
    }
}
#endif
