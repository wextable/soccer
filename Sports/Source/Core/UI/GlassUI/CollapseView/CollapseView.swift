//
//  CollapseView.swift
//  GlassUI
//
//  Created by Alex Johnson on 1/8/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import UIKit

/// A container view that supports collapsing and expanding its content view in any direction via animatable layout
/// constraints.
///
/// The default state is expanded. Manage collapsing and expanding with the `isCollapsed` property.
///
/// ```
/// let myView = MyView()
/// let collapseView = CollapseView(contentView: myView)
///
/// // no animation
/// collapseView.isCollapsed = true
///
/// // animation
/// UIView.animate(withDuration: 0.5) {
///     collapseView.isCollapsed = true
/// }
/// ```
public class CollapseView<ContentView: UIView>: BaseView {

    public enum Edge {
        case top, leading, trailing, bottom

        public var axis: NSLayoutConstraint.Axis {
            switch self {
            case .leading, .trailing:
                return .horizontal
            case .top, .bottom:
                return .vertical
            }
        }
    }

    /// The content of the collapse view.
    public let contentView: ContentView

    public var accessibilityDescriptor: String {
        return isCollapsed ? "Collapsed".localize(): "Expanded".localize()
    }

    /// A Boolean value indicating whether the view is collapsed or expanded.
    public var isCollapsed: Bool {
        get { collapseConstraint.isActive }
        set {
            collapseConstraint.isActive = newValue
        }
    }

    private var collapseConstraint: NSLayoutConstraint!

    /// Creates a new collapse view with the given content.
    /// - Parameters:
    ///   - contentView: The content to display inside the collapse view.
    ///   - collapseToEdge: The edge to which the view should collapse.
    ///   - isCollapsed: The initial collapsed/expanded state of the view.
    ///   - layoutMargins: The space between the view's edges and those of its content view.
    public init(
        contentView: ContentView,
        collapseToEdge: Edge = .top,
        isCollapsed: Bool = false,
        layoutMargins: UIEdgeInsets = .zero
    ) {
        self.contentView = contentView

        super.init(frame: contentView.frame)

        self.accessibilityTraits = UIAccessibilityTraits.button

        clipsToBounds = true
        self.layoutMargins = layoutMargins

        addAutoLayoutSubview(contentView)

        let topConstraint = contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        let leadingConstraint = contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        let trailingConstraint = contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)

        switch collapseToEdge {
        case .top:
            topConstraint.priority = .defaultLow
        case .leading:
            leadingConstraint.priority = .defaultLow
        case .trailing:
            trailingConstraint.priority = .defaultLow
        case .bottom:
            bottomConstraint.priority = .defaultLow
        }

        NSLayoutConstraint.activate(topConstraint, leadingConstraint, trailingConstraint, bottomConstraint)

        switch collapseToEdge.axis {
        case .horizontal:
            collapseConstraint = widthAnchor.constraint(equalToConstant: 0)
        case .vertical:
            collapseConstraint = heightAnchor.constraint(equalToConstant: 0)
        @unknown default:
            fatalError("Unknown `UIStackView.Axis` axis=\(collapseToEdge.axis)")
        }

        self.isCollapsed = isCollapsed
    }
}
