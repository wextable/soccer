//
//  FiveStarRatingView.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import UIKit

class FiveStarRatingView: BaseView {

    // MARK: Properties

    private let containerView = UIView()
    private let stackView = UIStackView(axis: .horizontal)
    private let starViews: [StarRatingView] = [
        .init(), .init(), .init(), .init(), .init()
    ]

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        backgroundColor = .clear
        stackView.spacing = 1.0
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews(starViews)
        containerView.addAutoLayoutSubview(stackView)
        addAutoLayoutSubview(containerView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let starSize: CGFloat = 17.0

        for starView in starViews {
            NSLayoutConstraint.activate(
                starView.widthAnchor.constraint(equalToConstant: starSize)
            )
        }

        NSLayoutConstraint.activate(
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerView.constraints(pinningTo: self),
            heightAnchor.constraint(equalToConstant: starSize),
            widthAnchor.constraint(greaterThanOrEqualToConstant: (starSize + 1) * 5)
        )
    }
}

extension FiveStarRatingView {
    struct Model: Hashable {
        var rating: Double = 0
        var maxRating: Double = 5
    }

    private func applyModel() {
        let doubleRating = (model.rating * 2).rounded()
        let ratingToTheHalf = Double(doubleRating) / 2.0
        let doubleMaxRating = (model.maxRating * 2).rounded()
        let maxRatingToTheHalf = Double(doubleMaxRating) / 2.0

        for i in 1...starViews.count {
            var backgroundSize = StarRatingView.Model.Size.none
            if maxRatingToTheHalf >= Double(i) {
                backgroundSize = .full
            } else if maxRatingToTheHalf >= Double(i) - 0.5 {
                backgroundSize = .half
            }
            var foregroundSize = StarRatingView.Model.Size.none
            if ratingToTheHalf >= Double(i) {
                foregroundSize = .full
            } else if ratingToTheHalf >= Double(i) - 0.5 {
                foregroundSize = .half
            }

            starViews[i-1].model = .init(backgroundSize: backgroundSize,
                                         foregroundSize: foregroundSize)
        }
    }
}

class StarRatingView: BaseView {

    // MARK: Properties

    private let backgroundImageView = UIImageView()
    private let foregroundImageView = UIImageView()

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        backgroundColor = .clear
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(backgroundImageView)
        addAutoLayoutSubview(foregroundImageView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            backgroundImageView.constraints(pinningTo: self),
            foregroundImageView.constraints(pinningTo: self)
        )
    }
}

extension StarRatingView {
    struct Model: Hashable {

        enum Size {
            case none
            case half
            case full
        }

        var backgroundSize: Size = .full
        var foregroundSize: Size = .full
    }

    private func applyModel() {
        switch model.backgroundSize {
        case .none: backgroundImageView.image = nil
        case .half: backgroundImageView.image = UIImage(named: "star_half_gray")
        case .full: backgroundImageView.image = UIImage(named: "star_full_gray")
        }
        switch model.foregroundSize {
        case .none: foregroundImageView.image = nil
        case .half: foregroundImageView.image = UIImage(named: "star_half")
        case .full: foregroundImageView.image = UIImage(named: "star_full")
        }
    }
}
