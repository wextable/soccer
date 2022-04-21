//
//  GameScheduleView.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

class GameScheduleView: BaseView {

    // MARK: Properties
    private let stackView = UIStackView(axis: .horizontal)
    private let awayRankingLabel = GlassLabel(style: .body2)
    private let awayTeamView = TeamIconNameView()
    private let scoreLabel = GlassLabel(style: .body2)
    private let homeRankingLabel = GlassLabel(style: .body2)
    private let homeTeamView = TeamIconNameView()

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
        scoreLabel.textAlignment = .center
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            awayRankingLabel,
            awayTeamView,
            scoreLabel,
            homeRankingLabel,
            homeTeamView
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let rankWidth = 33.0
        let teamWidth = 160.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            awayRankingLabel.widthAnchor.constraint(equalToConstant: rankWidth),
            awayTeamView.widthAnchor.constraint(equalToConstant: teamWidth),
            scoreLabel.widthAnchor.constraint(equalToConstant: 60.0),
            homeRankingLabel.widthAnchor.constraint(equalToConstant: rankWidth),
            homeTeamView.widthAnchor.constraint(equalToConstant: teamWidth)
        )
    }
}

extension GameScheduleView {
    struct Model: Hashable {
        var id: String = ""
        var awayRanking: String = ""
        var awayTeamModel: TeamIconNameView.Model?
        var score: String = ""
        var homeRanking: String = ""
        var homeTeamModel: TeamIconNameView.Model?
    }

    private func applyModel() {
        awayRankingLabel.text = model.awayRanking
        if let awayTeamModel = model.awayTeamModel {
            awayTeamView.model = awayTeamModel
        }
        awayTeamView.isHidden = model.awayTeamModel == nil

        scoreLabel.text = model.score

        homeRankingLabel.text = model.homeRanking
        if let homeTeamModel = model.homeTeamModel {
            homeTeamView.model = homeTeamModel
        }
        homeTeamView.isHidden = model.homeTeamModel == nil
    }
}

