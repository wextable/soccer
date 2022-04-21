///
///  ElevatingView.swift
///  GlassUI
///
///  Created by Eric Reedy on 11/12/20.
///  Copyright © 2020 Walmart. All rights reserved.
///
// swiftlint:disable double_space

import UIKit

///
/// This is the `BaseView` class intended to be used when satisfying
/// [Living Design Spec](https://app.zeplin.io/project/5e87d2e78e5f6020f1c99106/screen/5f0645cd774a407d05725f5c)
/// -derived requirements which may feature an elevation-based drop shadowed appearance.  Such elements should each
/// correspond with a specified elevation level, and should feature one of several specific filled or outlined
/// appearances.  This view is designed to be configured with one of each.
///
open class ElevatingView: BaseView, Elevatable {

    public var appearance: LDViewAppearance     { didSet { updateFromAppearance() } }
    public var elevationLevel: LDElevationLevel { didSet { updateFromElevation() } }

    ///
    /// Initializes and returns a newly allocated view object with the specified `appearance`, `elevationLevel`, and
    /// `frame`.
    ///
    /// - parameter appearance: The Appearance of the view, specifying either a fill or a border style. (Defaults to
    /// .unspecified)
    /// - parameter elevationLevel: The level of elevation, specifying the prominence of drop shadow. (Defaults to
    /// .zero)
    /// - parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative
    /// to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds
    /// properties accordingly.  (Defaults to .zero)
    ///
    public init(withAppearance appearance: LDViewAppearance = .unspecified,
                elevationLevel: LDElevationLevel = .zero,
                frame: CGRect = .zero)
    {
        self.appearance = appearance
        self.elevationLevel = elevationLevel
        super.init(frame: frame)

        updateFromAppearance()
        updateFromElevation()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
}
