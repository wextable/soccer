//
//  DebugPanelContainerCell.swift
//  DebugPanel
//
//  Created by Bharath Rao on 15/01/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

#if DEBUG
import UIKit

class DebugPanelContainerCell: BaseTableViewCell {

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        customizeCell()
    }

    private func customizeCell() {
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.minimumScaleFactor = 0.5
        detailTextLabel?.numberOfLines = 0
    }

    /// TableViewCell model
    struct GridModel {
        var title: String
        var subtitle: String
    }

    var model: GridModel? {
        didSet {
            textLabel?.text = model?.title
            detailTextLabel?.text = model?.subtitle
        }
    }
}
#endif
