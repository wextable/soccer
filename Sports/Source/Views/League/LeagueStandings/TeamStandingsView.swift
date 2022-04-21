//
//  TeamStandingsView.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

class TeamStandingsView: BaseView {

    // MARK: Properties
    // weak var delegate: HomeViewControllerDelegate?

    private let stackView = UIStackView(axis: .horizontal)
    private let rankingLabel = GlassLabel(style: .body2)
    private let teamView = TeamIconNameView()
    private let winsLabel = GlassLabel(style: .body2)
    private let drawsLabel = GlassLabel(style: .body2)
    private let lossesLabel = GlassLabel(style: .body2)
    private let pointsLabel = GlassLabel(style: .body2)
    private let goalsForLabel = GlassLabel(style: .body2)
    private let goalsAgainstLabel = GlassLabel(style: .body2)
    private let goalDifferentialLabel = GlassLabel(style: .body2)
    private let offenseLabel = GlassLabel(style: .body2)
    private let defenseLabel = GlassLabel(style: .body2)
    private let overallLabel = GlassLabel(style: .body2)

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
            teamView,
            winsLabel,
            drawsLabel,
            lossesLabel,
            pointsLabel,
            goalsForLabel,
            goalsAgainstLabel,
            goalDifferentialLabel,
            offenseLabel,
            defenseLabel,
            overallLabel
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let standardWidth = 33.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            rankingLabel.widthAnchor.constraint(equalToConstant: 20),
            teamView.widthAnchor.constraint(equalToConstant: 140),
            winsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            drawsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            lossesLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            pointsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            goalsForLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            goalsAgainstLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            goalDifferentialLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            offenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            defenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            overallLabel.widthAnchor.constraint(equalToConstant: standardWidth)
        )
    }
}

extension TeamStandingsView {
    struct Model: Hashable {
        var id: String = ""
        var ranking: String = ""
        var teamModel: TeamIconNameView.Model = .init()
        var wins: String = ""
        var draws: String = ""
        var losses: String = ""
        var points: String = ""
        var goalsFor: String = ""
        var goalsAgainst: String = ""
        var goalDifferential: String = ""
        var offense: String = ""
        var defense: String = ""
        var overall: String = ""
    }

    private func applyModel() {
        rankingLabel.text = model.ranking
        teamView.model = model.teamModel
        winsLabel.text = model.wins
        drawsLabel.text = model.draws
        lossesLabel.text = model.losses
        pointsLabel.text = model.points
        goalsForLabel.text = model.goalsFor
        goalsAgainstLabel.text = model.goalsAgainst
        goalDifferentialLabel.text = model.goalDifferential
        offenseLabel.text = model.offense
        defenseLabel.text = model.defense
        overallLabel.text = model.overall
    }
}
