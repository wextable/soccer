//
//  TeamGameScheduleView.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

class TeamGameScheduleView: BaseView {

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

        let rankingWidth = 33.0
        let teamWidth = 160.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            awayRankingLabel.widthAnchor.constraint(equalToConstant: rankingWidth),
            awayTeamView.widthAnchor.constraint(equalToConstant: teamWidth),
            scoreLabel.widthAnchor.constraint(equalToConstant: 60),
            homeRankingLabel.widthAnchor.constraint(equalToConstant: rankingWidth),
            homeTeamView.widthAnchor.constraint(equalToConstant: teamWidth)
        )
    }
}

extension TeamGameScheduleView {
    struct Model: Hashable {
        var id: String = ""
        var awayRanking: String = ""
        var awayTeamModel: TeamIconNameView.Model = .init()
        var score: String = ""
        var homeRanking: String = ""
        var homeTeamModel: TeamIconNameView.Model = .init()
    }

    private func applyModel() {
        awayRankingLabel.text = model.awayRanking
        awayTeamView.model = model.awayTeamModel
        scoreLabel.text = model.score
        homeRankingLabel.text = model.homeRanking
        homeTeamView.model = model.homeTeamModel
    }
}

