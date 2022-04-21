//
//  ViewConstructable.swift
//  GlassUI
//
//  Created by Alex Johnson on 11/13/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

/// This protocol defines the phases of view construction.
///
/// When conforming to this protocol, implement the construction phaeses and call `construct()` as soon as the primary
/// view is available.

import Foundation

@objc public protocol ViewConstructable {

    /// Provides a call to inform the conforming object that the view is about to begin construction
    ///
    /// **Do not call this method directly.** Conforming types should trigger this method by calling `construct()`.
    @objc optional func viewWillConstruct()

    /// Provides a call to inform the conforming object that the view has finished construction
    ///
    /// **Do not call this method directly.** Conforming types should trigger this method by calling `construct()`.
    @objc optional func viewDidConstruct()

    /// Configures the primary view
    ///
    /// **Do not call this method directly.** Conforming types should trigger this method by calling `construct()`.
    func constructView()

    /// Assembles subviews into the correct hierarchy
    ///
    /// **Do not call this method directly.** Conforming types should trigger this method by calling `construct()`.
    func constructSubviewHierarchy()

    /// Adds layout constraints and sets layout-related properties
    ///
    /// **Do not call this method directly.** Conforming types should trigger this method by calling `construct()`.
    func constructSubviewLayoutConstraints()
}

public extension ViewConstructable {
    func construct() {
        viewWillConstruct?()
        constructView()
        constructSubviewHierarchy()
        constructSubviewLayoutConstraints()
        viewDidConstruct?()
    }

    // Note: Do not add default implementations of the `constructX()` methods. Default implementations are not
    // compatible with subclassing.
}
