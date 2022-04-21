//
//  PlayerListingView.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

class PlayerListingView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let positionLabel = GlassLabel(style: .body2)
    private let nameLabel = GlassLabel(style: .body2)
    // morale
    // condition
    private let overallLabel = GlassLabel(style: .body2)
    private let overallRatingView = FiveStarRatingView()
    private let offenseLabel = GlassLabel(style: .body2)
    private let defenseLabel = GlassLabel(style: .body2)
    private let goalsLabel = GlassLabel(style: .body2)
    private let assistsLabel = GlassLabel(style: .body2)
    private let savesLabel = GlassLabel(style: .body2)
    private let cleanSheetsLabel = GlassLabel(style: .body2)

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
        stackView.distribution = .fillProportionally
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            positionLabel,
            nameLabel,
            overallLabel,
            overallRatingView,
            offenseLabel,
            defenseLabel,
            goalsLabel,
            assistsLabel,
            savesLabel,
            cleanSheetsLabel
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let standardWidth = 35.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            positionLabel.widthAnchor.constraint(equalToConstant: standardWidth),
//            nameLabel.widthAnchor.constraint(equalToConstant: 100.0),
            overallRatingView.widthAnchor.constraint(equalToConstant: 120),
            overallLabel.widthAnchor.constraint(equalToConstant: standardWidth * 3),
            offenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            defenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            goalsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            assistsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            savesLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            cleanSheetsLabel.widthAnchor.constraint(equalToConstant: standardWidth)
        )
    }
}

extension PlayerListingView {
    struct Model: Hashable {
        var id: String = ""
        var position: String = ""
        var positionColor: UIColor = GlassColor.gray140.uiColor
        var name: String = ""
        var overallText: String?
        var overallRatingOutOfFive: Double?
        var overallPotentialOutOfFive: Double?
        var offense: String = ""
        var defense: String = ""
        var goals: String = ""
        var assists: String = ""
        var saves: String = ""
        var cleanSheets: String = ""
    }

    private func applyModel() {
        positionLabel.text = model.position
        positionLabel.textColor = model.positionColor
        nameLabel.text = model.name

        if let overallText = model.overallText {
            overallLabel.text = overallText
            overallLabel.isHidden = false
            overallRatingView.isHidden = true
        } else if let overallRatingOutOfFive = model.overallRatingOutOfFive,
                  let overallPotentialOutOfFive = model.overallPotentialOutOfFive {
            overallLabel.isHidden = true
            overallRatingView.model = .init(rating: overallRatingOutOfFive,
                                            maxRating: overallPotentialOutOfFive)
            overallRatingView.isHidden = false
        }

        offenseLabel.text = model.offense
        defenseLabel.text = model.defense
        goalsLabel.text = model.goals
        assistsLabel.text = model.assists
        savesLabel.text = model.saves
        cleanSheetsLabel.text = model.cleanSheets
    }
}

