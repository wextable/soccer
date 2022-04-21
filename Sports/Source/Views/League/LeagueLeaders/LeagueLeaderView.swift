//
//  LeagueLeaderView.swift
//  Sports
//
//  Created by Wesley St. John on 1/2/22.
//

import UIKit

class LeagueLeaderView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let rankingLabel = GlassLabel(style: .body2)
    private let positionLabel = GlassLabel(style: .body2)
    private let nameLabel = GlassLabel(style: .body2)
    private let teamView = TeamIconNameView()
    private let goalsLabel = GlassLabel(style: .body2)
    private let assistsLabel = GlassLabel(style: .body2)
    private let savesLabel = GlassLabel(style: .body2)
    private let cleanSheetsLabel = GlassLabel(style: .body2)
    private let overallLabel = GlassLabel(style: .body2)
    private let overallRatingView = FiveStarRatingView()

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
            rankingLabel,
            positionLabel,
            nameLabel,
            teamView,
            goalsLabel,
            assistsLabel,
            savesLabel,
            cleanSheetsLabel,
            overallLabel,
            overallRatingView
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        rankingLabel.setContentHuggingPriority(.required, for: .horizontal)
        positionLabel.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        goalsLabel.setContentHuggingPriority(.required, for: .horizontal)
        assistsLabel.setContentHuggingPriority(.required, for: .horizontal)
        savesLabel.setContentHuggingPriority(.required, for: .horizontal)
        cleanSheetsLabel.setContentHuggingPriority(.required, for: .horizontal)
        overallLabel.setContentHuggingPriority(.required, for: .horizontal)

        let standardWidth = 35.0
        let ratingWidth = 90.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            rankingLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            positionLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            teamView.widthAnchor.constraint(equalToConstant: 160.0),
            goalsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            assistsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            savesLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            cleanSheetsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            overallLabel.widthAnchor.constraint(equalToConstant: ratingWidth),
            overallRatingView.widthAnchor.constraint(equalToConstant: ratingWidth)
        )
    }
}

extension LeagueLeaderView {
    struct Model: Hashable {
        var id: String = ""
        var ranking: String = ""
        var position: String = ""
        var positionColor: UIColor = .white
        var name: String = ""
        var teamModel: TeamIconNameView.Model = .init()
        var goals: String = ""
        var assists: String = ""
        var saves: String = ""
        var cleanSheets: String = ""
        var overallText: String?
        var overallRatingOutOfFive: Double?
        var overallPotentialOutOfFive: Double?
    }

    private func applyModel() {
        rankingLabel.text = model.ranking
        positionLabel.text = model.position
        positionLabel.textColor = model.positionColor
        nameLabel.text = model.name
        teamView.model = model.teamModel
        goalsLabel.text = model.goals
        assistsLabel.text = model.assists
        savesLabel.text = model.saves
        cleanSheetsLabel.text = model.cleanSheets
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
    }
}


