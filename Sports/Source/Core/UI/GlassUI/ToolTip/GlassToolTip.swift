//
//  GlassToolTip.swift
//  GlassUI
//
//  Created by Bharath Rao on 12/10/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// Zeplin Specs : https://zpl.io/adJ8Zd5
///
///          EasyTipView
/// ______________▲_________________
/// |  Get started by selecting     |
/// |   a size from the list.       |
/// |_______________________________|
///

/// Provides call back when tooltip is dismissed
public protocol GlassToolTipDelegate: AnyObject {

    /// Dismissal of tooltip
    func didDismissToolTip(_ toolTip : GlassToolTip)
}

public class GlassToolTip: BaseView {

    // MARK: Private members

    /// Text to be displayed in tooltip
    private var sourceText: String

    /// Reference view from which tooltip is displayed
    private var referenceView: UIView

    /// Optional view to anchor the tooltip to. Useful if you want your tooltip to scroll with this view
    private var parentView: UIView?

    /// Preferred arrow direction of tooltip
    private var preferredArrowDirection: ArrowDirection = .any

    /// Preference to configure EasyTipView
    private var toolTipPreference = EasyTipView.globalPreferences

    /// EasyTipView
    private var easyTipView: EasyTipView?

    /// Configure attributes for tooltip
    private struct Configure {
        static let arrowHeight     = CGFloat(8.0)
        static let arrowWidth      = CGFloat(16.0)
        static let cornerRadius    = CGFloat(12.0)
        static let horizontalInset = CGFloat(16.0)
        static let VerticalInset   = CGFloat(7.0)
        static let maxWidthPercent = CGFloat(0.5)
    }

    // MARK: Public members

    /// Delegate to receive call back on tooltip dismissal
    public weak var toolTipDelegate: GlassToolTipDelegate?

    /**
     GlassToolTip allows features to add a tooltip on UI components

     - Parameters:
        - text: Text to be displayed in tooltip
        - font: Text font. Defaults to GlassFont.body2().uiFont
        - sourceView: Source view from where the tooltip is displayed
        - parentView: Optional view to anchor the tooltip to. Useful if you want your tooltip to scroll with this view
        - arrowDirection: Direction of tooltip arrow. Defaults to top ⬆️
        - delegate: Delegate to get callback

     ## Zeplin Specs:
     [https://zpl.io/adJ8Zd5](https://zpl.io/adJ8Zd5)

     ## Sample code snippet
     ```
     let toolTip = GlassToolTip(with: "S", font: font, sourceView: someUIView, arrowDirection: .left, delegate: self)
     ```
     ## Handling callback
     ```
     extension ToolTipView: GlassToolTipDelegate {
        func didDismissToolTip(_ toolTip: GlassToolTip) {
            //Handle callback
        }
     }
     ```
     */

    required
    public init(with text: String,
                font: UIFont = GlassFont.body2().uiFont,
                sourceView: UIView,
                parentView: UIView? = nil,
                arrowDirection: ArrowDirection = .any,
                delegate: GlassToolTipDelegate? = nil) {
        sourceText = text
        referenceView = sourceView
        self.parentView = parentView
        toolTipDelegate = delegate
        preferredArrowDirection = arrowDirection
        super.init(frame: .zero)
        accessibilityLabel = text
        configureToolTipPreference(font: font)
        setupToolTipView()
    }

    /// Dismiss tooltip
    public func dismissToolTip() {
        easyTipView?.dismiss()
    }

    // MARK: EasyTipView

    /// Configure preference for EasyTipView
    private func configureToolTipPreference(font: UIFont) {
        toolTipPreference.drawing.foregroundColor   = GlassColor.gray200.uiColor
        toolTipPreference.drawing.backgroundColor   = GlassColor.yellow100.uiColor
        toolTipPreference.drawing.font              = font
        toolTipPreference.drawing.arrowHeight       = Configure.arrowHeight
        toolTipPreference.drawing.arrowWidth        = Configure.arrowWidth
        toolTipPreference.drawing.cornerRadius      = Configure.cornerRadius
        toolTipPreference.positioning.contentHInset = Configure.horizontalInset
        toolTipPreference.positioning.contentVInset = Configure.VerticalInset
        toolTipPreference.positioning.maxWidth      = UIScreen.main.bounds.width * Configure.maxWidthPercent
        toolTipPreference.drawing.arrowPosition     = preferredArrowDirection.resolvedPosition()
    }

    /*
     Note: 📝
     We use `EasyTipView` to display a tooltip from the reference frame
     While most of the code in EasyTipView.swift is used from the original git version,
     (https://github.com/teodorpatras/EasyTipView/releases/tag/2.0.4),
     some syntax changes are made to silence swift lint warnings.
     Access specifiers are made internal/fileprivate instead of public/open
     Accessibility support has been added which was not provided in git version
     Also, swift version checks were removed as GlassStyles is already on Swift-5.0
    */
    /// Setup & display EasyTipView from reference view
    private func setupToolTipView() {
        easyTipView = EasyTipView(text: sourceText, preferences: toolTipPreference, delegate: self)
        //Disabling animation as we don't have any specs for animation
        easyTipView?.show(animated: false, forView: referenceView, withinSuperview: parentView)
    }
}

extension GlassToolTip {

    /// Direction of tooltip arrow
    ///
    /// - up: Arrow pointing upwards      🔼
    /// - down: Arrow pointing downwards  🔽
    /// - right: Arrow pointing right     ▶️
    /// - left: Arrow pointing left       ◀️
    /// - any: Defaults to arrow upwards  🔼
    public enum ArrowDirection {
        case up
        case down
        case right
        case left
        case any

        /// Method to resolve the arrow position as type EasyTipView.ArrowPosition
        ///
        /// - Returns: EasyTipView.ArrowPosition
        func resolvedPosition() -> EasyTipView.ArrowPosition {
            switch self {
            case .up, .any:
                return .top
            case .down:
                return .bottom
            case .right:
                return .right
            case .left:
                return .left
            }
        }
    }
}

// MARK: EasyTipViewDelegate

extension GlassToolTip: EasyTipViewDelegate {
    //Dismissal action
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        self.toolTipDelegate?.didDismissToolTip(self)
    }
}
