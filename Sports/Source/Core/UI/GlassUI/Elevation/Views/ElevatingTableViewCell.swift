///
///  ElevatingTableViewCell.swift
///  GlassUI
///
///  Created by Eric Reedy on 12/22/20.
///  Copyright © 2020 Walmart. All rights reserved.
///
// swiftlint:disable double_space

import UIKit

///
/// This is the `BaseTableViewCell` class intended to be used when satisfying
/// [Living Design Spec](https://app.zeplin.io/project/5e87d2e78e5f6020f1c99106/screen/5f0645cd774a407d05725f5c)
/// -derived requirements which may feature an elevation-based drop shadowed appearance.  Such elements should each
/// correspond with a specified elevation level, and should feature one of several specific filled or outlined
/// appearances. This view is designed to be
/// configured with one of each.
///
open class ElevatingTableViewCell: BaseTableViewCell, Elevatable {

    public var appearance: LDViewAppearance = .filledWhite { didSet { updateFromAppearance() } }
    public var elevationLevel: LDElevationLevel = .zero    { didSet { updateFromElevation() } }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
}
