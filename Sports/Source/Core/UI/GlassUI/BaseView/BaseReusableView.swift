//
//  BaseReusableView.swift
//  GlassUI
//
//  Created by John Liedtke on 1/18/19.
//  Copyright © 2019 WalmartLabs. All rights reserved.
//

import Foundation

/// A protocol for reusable views that gives each type a static `reuseIdentifier` based on the class name.
public protocol BaseReusableView {
    /// The standard reuse identifier for this view
    ///
    /// A default implementation is provided. Conforming types will rarely (if ever) need to implement this themselves.
    ///
    /// See also:
    /// - `UITableView.register(_:)`
    /// - `UITableView.dequeueCell(for:of:)`
    /// - `UITableView.dequeueHeaderFooterView(for:of:)`
    /// - `UICollectionView.register(_:)`
    /// - `UICollectionView.dequeueCell(for:of:)`
    /// - `UICollectionView.register(_:ofKind:)`
    /// - `UICollectionView.dequeueReusableView(for:of:ofKind)`
    static var reuseIdentifier: String { get }
}

public extension BaseReusableView {
    static var reuseIdentifier: String {
        return "com.walmart.\(String(describing: self))"
    }
}

extension BaseCollectionViewCell: BaseReusableView {}
extension BaseCollectionReusableView: BaseReusableView {}
extension BaseTableViewCell: BaseReusableView {}
extension BaseTableViewHeaderFooterView: BaseReusableView {}
