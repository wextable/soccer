//
//  GlassLoadingView.swift
//  GlassUI
//
//  Created by John Liedtke on 5/28/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A simple view that displays an active and centered `LoadingIndicatorView`. Particularly useful for "view swapping",
/// e.g. replacing a `UITableView` when an asynchronous task is in progress.
public class GlassLoadingView: BaseView {

    public var isIndicatorHidden: Bool {
        get { indicatorView.isHidden }
        set { indicatorView.isHidden = newValue }
    }

    let indicatorView: GlassActivityIndicator

    public init(style: GlassActivityIndicator.ViewStyle = .medium,
                backgroundColor: UIColor = GlassColor.gray00.uiColor) {
        indicatorView = GlassActivityIndicator(style: style)

        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        addAutoLayoutSubview(indicatorView)

        NSLayoutConstraint.activate(indicatorView.constraints(centeringInside: self))
        isAccessibilityElement = true
        accessibilityLabel = "Loading"
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            indicatorView.stopAnimating()
        }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil else { return }

        indicatorView.startAnimating()
    }
}
