//
//  Scrollbar.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/28/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public class GlassScrollbar: UIView {
    let currentView: UIView = UIView(frame: .zero)
    public var pageCount: Int = 1 {
        didSet {
            guard pageCount > 0 else { return }
            let newWidth = width / CGFloat(pageCount)
            updateCurrentViewWidth(newWidth)
        }
    }

    private enum Constant {
        static let width: CGFloat = 200
    }

    private var width: CGFloat = Constant.width

    public var currentPageIndex: Int = 0 {
        didSet {
            updateCurrentPageView(oldLocation: oldValue, newLocation: currentPageIndex)
        }
    }

    internal var indicatorLeadingConstraint: NSLayoutConstraint?
    internal var currentViewWidthConstraint: NSLayoutConstraint?

    public init(pageCount: Int, scrollbarWidth: CGFloat = 200) {
        super.init(frame: .zero)
        self.pageCount = pageCount
        self.width = scrollbarWidth
        postInit()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not defined")
    }

    func setConstraints() {
        self.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false

        indicatorLeadingConstraint = currentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        let currentViewWidth = pageCount > 0 ? width / CGFloat(pageCount) : width
        currentViewWidthConstraint = currentView.widthAnchor.constraint(equalToConstant: currentViewWidth)
        let constraints = [
            heightAnchor.constraint(equalToConstant: 2.0),
            widthAnchor.constraint(equalToConstant: width),
            indicatorLeadingConstraint,
            currentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            currentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            currentViewWidthConstraint
        ]

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(constraints)
    }

    func postInit() {
        currentView.backgroundColor = GlassColor.gray200.uiColor
        self.backgroundColor = GlassColor.gray50.uiColor
        setConstraints()
    }

    func updateCurrentPageView(oldLocation: Int, newLocation: Int) {
        UIView.animate(withDuration: GlassAnimation.animationTimeMedium) { [weak self] in
            guard let self = self else { return }
            let widthOfSelected = self.currentView.frame.width
            let diff = newLocation - oldLocation
            self.indicatorLeadingConstraint?.constant += CGFloat(diff) * CGFloat(widthOfSelected)

            self.layoutIfNeeded()
        }
    }

    func updateCurrentViewWidth(_ newWidth: CGFloat) {
        guard let currentViewWidthConstraint = currentViewWidthConstraint else { return }
        currentViewWidthConstraint.constant = newWidth
        layoutIfNeeded()
    }
}
