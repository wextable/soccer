//
//  PlayerRatingView.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import UIKit

class PlayerRatingView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let nameLabel = GlassLabel(style: .body2)
    private let ratingBar = BarRatingView()

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

        backgroundColor = .white
        stackView.spacing = GlassSpacing.xSmall
        nameLabel.textAlignment = .right
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([nameLabel, ratingBar])
        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            nameLabel.widthAnchor.constraint(equalToConstant: 90),
            stackView.constraints(pinningTo: self),
            heightAnchor.constraint(equalToConstant: 24.0)
        )
    }
}

extension PlayerRatingView {
    struct Model: Hashable {
        var ratingType: Player.Rating = .speed
        var rating: Int = 0
        var potentialRating: Int = 1
    }

    private func applyModel() {
        nameLabel.text = model.ratingType.name
        ratingBar.model = .init(ratingPercent: Double(model.rating) / 100.0,
                                potentialRatingPercent: Double(model.potentialRating) / 100.0)
    }
}
