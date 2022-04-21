//
//  AutosizingTableView.swift
//  GlassUI
//
//  Created by Jordan Perry on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// `AutosizingTableView` provides a table view that can be used in place of a `UITableView` that will autosize based
/// on the table view's content size
public final class AutosizingTableView: UITableView {
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return .init(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
