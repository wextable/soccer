//
//  GlassUserStarView.swift
//  GlassUI
//
//  Created by Vishal Madheshia on 05/29/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

class GlassUserStarView: UIView {

    enum State {
        case selected, unselected
    }

    public var model: Model {
        didSet { applyModel() }
    }

    private let iconView = UIImageView()

    init(frame: CGRect = .zero, model: GlassUserStarView.Model = .init()) {
        self.model = model
        super.init(frame: frame)

        addAutoLayoutSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        applyModel()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - GlassUserStarView ViewModel
extension GlassUserStarView {
    /// A view model for configuring a `GlassUserStarView` instance.
    public struct Model {
        var state: State
        var size: GlassIcon.Size
        var fillStarIcon: GlassIcon
        var starIcon: GlassIcon
        var rating: Int

        init(state: State = .unselected,
             size: GlassIcon.Size = .size32,
             fillStarIcon: GlassIcon = .starFill,
             starIcon: GlassIcon = .star,
             rating: Int = 0) {
            self.state = state
            self.size = size
            self.fillStarIcon = fillStarIcon
            self.starIcon = starIcon
            self.rating = rating
        }
    }
}

// MARK: - Apply Model

extension GlassUserStarView {

    private func applyModel() {
        let selectedIcon: GlassIcon
        switch model.state {
        case .selected:
            selectedIcon = model.fillStarIcon

        case .unselected:
            selectedIcon = model.starIcon
        }
        iconView.image = selectedIcon.image(model.size)
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassUserStarView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassUserStarView

        fileprivate init(target: GlassUserStarView) {
            self.target = target
        }

        var iconView: UIImageView {
            return target.iconView
        }
    }
}
#endif
