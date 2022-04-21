//
//  CoreDivider.swift
//  GlassUI
//
//  Created by Josh Mann on 4/16/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public enum DividerStyle {
    case list
    case inCard
    case vertical(CGFloat)
    case tile
}

/// A divider is a thin line that groups content in lists and layouts.
/// # Discussion
/// [Zeplin Reference](https://zpl.io/aXvzyYj)
///
/// # Example
/// ```swift
/// var divider = GlassDivider(frame: CGRect.zero, style: .list)
/// ```
public class GlassDivider: UIView {
    private let dividerView = UIView()

    public var dividerStyle: DividerStyle = .list {
        didSet { applyStyle() }
    }

    /// An optional override of the divider color.
    public var dividerColor: GlassColor? {
        didSet { applyStyle() }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.layoutFittingExpandedSize.width, height: dividerStyle.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    public init(frame: CGRect = .zero, style: DividerStyle) {
        self.dividerStyle = style
        super.init(frame: frame)
        postInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    private func postInit() {
        applyStyle()
        addAutoLayoutSubview(dividerView)

        setContentHuggingPriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func applyStyle() {
        layoutMargins = dividerStyle.layoutMargins
        dividerView.backgroundColor = dividerColor?.uiColor ?? dividerStyle.defaultColor.uiColor
    }
}

private extension DividerStyle {
    var layoutMargins: UIEdgeInsets {
        return .zero
    }

    var defaultColor: GlassColor {
        return GlassColor.gray10
    }

    var height: CGFloat {
        switch self {
        case .list, .inCard, .tile: return 1.0
        case .vertical(let height): return height
        }
    }
}
