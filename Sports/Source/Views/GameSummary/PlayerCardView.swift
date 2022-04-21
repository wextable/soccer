//
//  PlayerCardView.swift
//  Sports
//
//  Created by Wesley St. John on 4/18/22.
//

import UIKit

class PlayerCardView: BaseView {

    // MARK: Properties

    private let cardView = GlassCard(model: .init(style: .quarter))
    private let stackView = UIStackView(axis: .vertical)
    private let topContainer = BaseView()
    private let nameLabel = GlassLabel(style: .subheading2)
    private let imageView = UIImageView()
    private let positionContainer = BaseView()
    private let positionLabel = GlassLabel(style: .captionBold)
    private let ratingView = FiveStarRatingView()
    private let statsLabel = GlassLabel(style: .captionRegular)

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

        nameLabel.textAlignment = .center
        positionContainer.layer.borderWidth = 1.5
        positionContainer.layer.cornerRadius = 4.0
        positionContainer.clipsToBounds = true
        statsLabel.textAlignment = .center
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        positionContainer.addAutoLayoutSubview(positionLabel)
        topContainer.addAutoLayoutSubviews([
            imageView,
            nameLabel,
            positionContainer
        ])

        stackView.addArrangedSubviews([
            topContainer,
            ratingView,
            statsLabel
        ])
        cardView.addAutoLayoutSubview(stackView)
        addAutoLayoutSubview(cardView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let iconSize: CGFloat = 64.0
        NSLayoutConstraint.activate(
            nameLabel.topAnchor.constraint(equalTo: topContainer.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor,
                                              constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: iconSize),
            imageView.heightAnchor.constraint(equalToConstant: iconSize),
            imageView.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            positionLabel.constraints(pinningTo: positionContainer, insets: .init(floatLiteral: 4)),
            positionContainer.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            positionContainer.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor,
                                                       constant: GlassSpacing.xSmall),
            stackView.constraints(pinningTo: cardView),
            cardView.constraints(pinningTo: self)
        )
    }
}

extension PlayerCardView {
    struct Model: Hashable {
        var id: String = ""
        var name: String = ""
        var image: UIImage?
        var position: Position?
        var ratingOutOfFive: Double?
        var stats: String?
    }

    private func applyModel() {
        nameLabel.text = model.name
        imageView.image = model.image
        positionLabel.text = model.position?.shortName
        positionLabel.textColor = model.position?.color
        positionContainer.layer.borderColor = positionLabel.textColor.cgColor
        positionLabel.isHidden = model.position == nil

        if let rating = model.ratingOutOfFive {
            ratingView.model = .init(rating: rating, maxRating: rating)
            ratingView.isHidden = false
        } else {
            ratingView.isHidden = true
        }

        statsLabel.text = model.stats
        statsLabel.isHidden = model.stats == nil
    }
}

