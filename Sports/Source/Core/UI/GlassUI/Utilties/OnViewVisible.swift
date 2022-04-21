//
//  OnViewVisible.swift
//  GlassUI
//
//  Created by John Liedtke on 9/7/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import Combine
import UIKit

/// An object that notifies an observer when a view becomes visible.
public class OnViewVisible {

    /// The vertical scroll view the view is contained in.
    ///
    /// The default value is `enclosingScrollView`.
    public var verticalScrollView: UIScrollView? {
        get { detector?.verticalScrollView }
        set { detector?.verticalScrollView = newValue }
    }

    /// The horizontal scroll view the view is contained in.
    ///
    /// The default value is `nil`.
    public var horizontalScrollView: UIScrollView? {
        get { detector?.horizontalScrollView }
        set { detector?.horizontalScrollView = newValue }
    }

    private var detector: VisibilityDetector?
    private var task: AnyCancellable?

    /// Creates a new object that executes a one-shot closure when the provided `view` becomes visible.
    ///
    /// - Parameters:
    ///   - view: The view to observe.
    ///   - visibilityThreshold: The required visibility for a view to considered visible. The default value
    ///   is `partial`.
    ///   - onVisible: A one-shot closure that is executed when `view` becomes visible.
    public init(
        view: UIView,
        visibilityThreshold: UIView.VisibilityThreshold = .partial,
        onVisible: @escaping () -> Void
    ) {
        detector = .init(view: view, visibilityThreshold: visibilityThreshold)

        task = detector?.visibilityPublisher
            .first(where: { isVisible in isVisible })
            .sink { [weak self] _ in
                // kill the detector to save resources
                self?.detector = nil
                onVisible()
            }
    }
}
