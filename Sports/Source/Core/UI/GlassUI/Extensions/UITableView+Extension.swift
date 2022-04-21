//
//  UITableView+Extension.swift
//  GlassUI
//
//  Created by Manoj Kumar Mahapatra on 5/6/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit.UITableView

public extension UITableView {
    /// Convenience method to register a cell of a particular type
    /// - Parameter type: type of the cell
    func register<Cell: BaseTableViewCell>(_ type: Cell.Type) {
        register(type, forCellReuseIdentifier: type.reuseIdentifier)
    }

    /// Convenience method to dequeue a cell of a particular type
    /// - Parameters:
    ///   - indexPath: IndexPath of the cell
    ///   - type: type of the cell, with a default value self
    ///
    ///- Returns: A valid `BaseTableViewCell` object or errors out
    func dequeueCell<Cell: BaseTableViewCell>(for indexPath: IndexPath, of type: Cell.Type = Cell.self) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("could not dequeue cell of type: \(Cell.self)")
        }
        return cell
    }

    /// Convenience method to register a view of a particular type
    /// - Parameter type: type of the view
    func register<View: BaseTableViewHeaderFooterView>(_ type: View.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier)
    }

    /// Convenience method to dequeue a headerfooter view of a particular type
    /// - Parameter type: type of the view, with a default value of self
    ///
    /// - Returns: A valid `BaseTableViewHeaderFooterView` object or errors out.
    func dequeueHeaderFooterView<View: BaseTableViewHeaderFooterView>(of type: View.Type = View.self) -> View {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier) as? View else {
            fatalError("could not dequeue headerfooter view of type: \(View.self)")
        }
        return view
    }
}
