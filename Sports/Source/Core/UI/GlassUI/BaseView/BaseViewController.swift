//
//  BaseViewController.swift
//  GlassUI
//
//  Created by David Yundt on 1/9/20.
//  Copyright © 2020 WalmartLabs. All rights reserved.
//

import Foundation
import os.log
import UIKit

/// A base class for `UIViewController`s in Glass.
///
/// The main feature of `BaseViewController` is conformance to `ViewConstructable`.
///
/// Subclasses that construct their own views should override the following methods (as needed):
///
/// - `constructView()`
/// - `constructSubviewHierarchy()`
/// - `constructSubviewLayoutConstraints()`
///
/// **Note:** Subclasses should be sure to call the superclass implementation when overriding these methods.
///
/// Alternatively, subclasses may choose to use a `BaseView` subclass of `BaseView` for their `view` class, in which
/// case the `ViewConstructable` methods can safely be ignored.
///
/// Secondary features include:
/// - Subclasses don't need to implement `init(coder:)`. `BaseViewController` marks that initializer as unavailable.
/// - Performance measurement metrics.
open class BaseViewController: UIViewController, ViewConstructable, Accessible {

    public static let pointsOfInterest = OSLog(subsystem: "com.walmart.glass", category: .pointsOfInterest)

    public enum SignpostMetricName {
        static let appearing: StaticString = "ViewControllerAppearing"
        static let loading: StaticString = "ViewControllerLoading"
    }

    public let signpostID: OSSignpostID!

    // MARK: - Initialization

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        signpostID = OSSignpostID(log: BaseViewController.pointsOfInterest)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) is not supported") }

    // MARK: - Lifecycle

    override open func loadView() {
        os_signpost(
            .begin,
            log: BaseViewController.pointsOfInterest,
            name: SignpostMetricName.loading,
            signpostID: signpostID
        )
        super.loadView()
    }

    override open func viewDidLoad() {
        defer {
            os_signpost(
                .end,
                log: BaseViewController.pointsOfInterest,
                name: SignpostMetricName.loading,
                signpostID: signpostID
            )
        }

        super.viewDidLoad()

        construct()
        assignAccessibilityIdentifiers()
    }

    override open func viewWillAppear(_ animated: Bool) {
        os_signpost(
            .begin,
            log: BaseViewController.pointsOfInterest,
            name: SignpostMetricName.appearing,
            signpostID: signpostID
        )
        super.viewWillAppear(animated)
    }

    override open func viewDidAppear(_ animated: Bool) {
        defer {
            os_signpost(
                .end,
                log: BaseViewController.pointsOfInterest,
                name: SignpostMetricName.appearing,
                signpostID: signpostID
            )
        }

        super.viewDidAppear(animated)
    }

    // MARK: - Construction

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

    /// Configures the `view`
    ///
    /// Override this method to set properties of the `view`, attach event listeners, etc.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructView() {}

    /// Assembles subviews into the correct hierarchy
    ///
    /// Override this method to set add subviews, or subviews of subviews, etc.
    ///
    /// **Tip:** Use `addAutoLayoutSubview()` to add a subview and also set `translatesAutoresizingMaskIntoConstraints`
    /// to `false` on it.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructSubviewHierarchy() {}

    /// Adds layout constraints and sets layout-related properties
    ///
    /// Override this method to set add layout constraints to subviews. If you need to adjust content-hugging and
    /// compression-resistance priorities, layout margins, or other layout-related properties, like the `spacing` of a
    /// `UIStackView`, do so in this method. Colocating all layout code in one method will make your code easier to
    /// understand.
    ///
    /// **Do not call this method directly.** It is part of the `ViewConstructable` protocol, and is called
    /// automatically as part of `init(frame:)`
    open func constructSubviewLayoutConstraints() {}
}
