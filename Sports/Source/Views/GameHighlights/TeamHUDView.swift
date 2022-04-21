//
//  TeamHUDView.swift
//  Sports
//
//  Created by Wesley St. John on 3/1/22.
//

import UIKit

class TeamHUDView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let teamIconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    var model: Model { didSet { applyModel() } }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        stackView.distribution = .fillProportionally
        nameLabel.textAlignment = .center
        nameLabel.font = .boldSystemFont(ofSize: 16)
        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 16, weight: .black)
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            teamIconImageView,
            nameLabel,
            scoreLabel
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            teamIconImageView.constraints(sizingTo: .init(width: 24, height: 24)),
            nameLabel.widthAnchor.constraint(equalToConstant: 45),
            scoreLabel.widthAnchor.constraint(equalToConstant: 15),
            stackView.constraints(pinningTo: self)
        )
    }
}

extension TeamHUDView {
    struct Model {
        var backgroundColor: UIColor = .white
        var textColor: UIColor = .black
        var teamIcon: UIImage?
        var teamName: String = ""
        var score: String = ""
        var isLeftAligned: Bool = true
    }

    private func applyModel() {
        backgroundColor = model.backgroundColor
        teamIconImageView.image = model.teamIcon
        nameLabel.text = model.teamName
        nameLabel.textColor = model.textColor
        scoreLabel.text = model.score
        scoreLabel.textColor = model.textColor

        stackView.removeAllArrangedSubviews()
        if model.isLeftAligned {
            stackView.addArrangedSubviews([
                teamIconImageView,
                nameLabel,
                scoreLabel
            ])
        } else {
            stackView.addArrangedSubviews([
                scoreLabel,
                nameLabel,
                teamIconImageView
            ])
        }
    }
}
