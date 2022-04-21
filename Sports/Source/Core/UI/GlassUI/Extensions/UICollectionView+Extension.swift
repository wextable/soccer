//
//  UICollectionView+Extension.swift
//  GlassUI
//
//  Created by Manoj Kumar Mahapatra on 5/6/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit.UICollectionView

public extension UICollectionView {
    /// Convenience method to register a cell of a particular type
    /// - Parameter type: type of the cell
    func register<Cell: BaseCollectionViewCell>(_ type: Cell.Type) {
        register(type, forCellWithReuseIdentifier: type.reuseIdentifier)
    }

    /// Convenience method to dequeue a cell of a particular type
    /// - Parameters:
    ///   - indexPath: indexPath of the cell
    ///   - type: type of the cell, with a default value self
    ///
    /// - Returns: A valid `BaseCollectionViewCell` object or errors out.
    func dequeueCell<Cell: BaseCollectionViewCell>(
        for indexPath: IndexPath,
        of type: Cell.Type = Cell.self
    ) -> Cell {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: type.reuseIdentifier,
            for: indexPath) as? Cell else {
                fatalError("could not dequeue cell of type: \(Cell.self)")
        }
        return cell
    }

    /// Convenience method to register a view of a particular type
    /// - Parameters:
    ///   - type: type of the view
    ///   - kind: kind of supplementary view to create. for example `UICollectionView.elementKindSectionHeader`
    func register<View: BaseCollectionReusableView>(
        _ type: View.Type,
        ofKind kind: String
    ) {
        register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.reuseIdentifier)
    }

    /// Convenience method to dequeue reusable view of a particular type
    /// - Parameters:
    ///   - indexPath: The index path specifying the location of the supplementary view in the collection view.
    ///   The data source receives this information when it is asked for the view and should just pass it along.
    ///   This method uses the information to perform additional configuration based on the view’s position
    ///   in the collection view.
    ///   - type: type of the view, with a default value self
    ///   - kind: kind of supplementary view to create. for example `UICollectionView.elementKindSectionHeader`
    ///
    /// - Returns: A valid `BaseCollectionReusableView` object or errors out.
    func dequeueReusableView<View: BaseCollectionReusableView>(
        for indexPath: IndexPath,
        of type: View.Type = View.self,
        ofKind kind: String
    ) -> View {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: type.reuseIdentifier,
            for: indexPath) as? View else {
                fatalError("could not dequeue reusable supplementaryView view of type: \(View.self)")
            }
        return view
    }
}
