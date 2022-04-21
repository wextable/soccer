//
//  CoreFlag.swift
//  GlassUI
//
//  Created by Owen Pierce on 4/17/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Flags are text content with a stylized border color that matches the label font color.
///
/// To get a solid flag background, set the style to `fill`.
///
/// # Reference
/// [Zeplin Reference](https://zpl.io/2yZJDZJ)
///
/// # Example
/// ```swift
/// let flag = GlassFlag(model: .init(text: "Rollback", flagColor: .red100, style: .outline))
/// let filledFlag = GlassFlag(model: .init(text: "Best Seller", color: GlassColor.blue100, style: .filled()))
/// ```
///
/// - Warning: Use ``GlassTag`` instead of GlassFlag
///
public class GlassFlag: BaseView {

    public var model: Model {
        didSet { applyModel(oldValue: oldValue) }
    }

    internal let label: UILabel

    public init(model: Model = Model()) {
        self.model = model
        label = UILabel()
        label.font = GlassFont.captionRegular().uiFont

        super.init(frame: .zero)

        applyModel(oldValue: nil)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(label)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        label.constraints(pinningTo: self,
                          edges: .all,
                          insets: .init(vertical: GlassSpacing.xxSmall,
                                        leading: GlassSpacing.xSmall,
                                        trailing: 0)).activate()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width + GlassSpacing.xSmall * 2,
                      height: label.intrinsicContentSize.height + GlassSpacing.xxSmall * 2)
    }

    private func applyModel(oldValue: Model?) {

        invalidateIntrinsicContentSize()
        switch model.style {
        case .outline:
            self.backgroundColor = GlassColor.clear.uiColor
            label.backgroundColor = GlassColor.clear.uiColor
        case .fill(textColor: _):
            self.backgroundColor = model.flagColor?.uiColor
            label.backgroundColor = model.flagColor?.uiColor
        }

        label.text = model.text
        label.textColor = model.textColor?.uiColor
        layer.borderWidth = 1
        layer.borderColor = model.flagColor?.uiColor.cgColor
        layer.cornerRadius = 2
    }
}
