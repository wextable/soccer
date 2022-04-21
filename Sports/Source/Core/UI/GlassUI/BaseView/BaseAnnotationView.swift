//
//  BaseAnnotationView.swift
//  GlassUI
//
//  Created by David Yundt on 2/5/20.
//  Copyright © 2020 WalmartLabs. All rights reserved.
//

import Foundation
import MapKit

/// A base class for `MKAnnotationView`s in Glass.
///
/// The main feature of `BaseAnnotationView` is conformance to `ViewConstructable`.
///
/// Subclasses should override the following methods (as needed) to construct themselves and their subviews:
///
/// - `constructView()`
/// - `constructSubviewHierarchy()`
/// - `constructSubviewLayoutConstraints()`
///
/// This class also adds an `applyAnnotation()` method that is called during initialization.
///
/// **Note:** Subclasses should be sure to call the superclass implementation when overriding these methods.
///
/// A secondary feature is that subclasses don't need to implement `init(coder:)`. `BaseAnnotationView` marks that
/// initializer as unavailable.
open class BaseAnnotationView: MKAnnotationView, BaseReusableView, ViewConstructable {

    override open var annotation: MKAnnotation? {
        didSet {
            applyAnnotation()
        }
    }

    // MARK: Initialization

    override public init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        construct()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) is not supported") }

    // MARK: Construction

    /// Provides a call to inform the conforming object that the view is about to begin construction
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func viewWillConstruct() {}

    /// Provides a call to inform the conforming object that the view has finished construction
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func viewDidConstruct() {}

    /// Constructs _this_ view
    ///
    /// Override this method to set properties of this view, attach event listeners to subviews, etc.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructView() {}

    /// Constructs the subview hierarchy
    ///
    /// Override this method to set add subviews, or subviews of subviews, etc.
    ///
    /// **Tip:** Use `addAutoLayoutSubview()` to add a subview and also set `translatesAutoresizingMaskIntoConstraints`
    /// to `false` on it.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructSubviewHierarchy() {}

    /// Constructs the subview hierarchy
    ///
    /// Override this method to set add layout constraints to subviews. If you need to adjust content-hugging and
    /// compression-resistance priorities, layout margins, or other layout-related properties, like the `spacing` of a
    /// `UIStackView`, do so in this method. Colocating all layout code in one method will make your code easier to
    /// understand.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructSubviewLayoutConstraints() {}

    /// Applies the `annotation`
    ///
    /// Override this method to update your view to match its `annotation`.
    ///
    /// **This method should not be called externally.** It is called automatically from
    /// `init(annotation:reuseIdentifier:)` and when setting the `annotation`.
    open func applyAnnotation() {}
}
