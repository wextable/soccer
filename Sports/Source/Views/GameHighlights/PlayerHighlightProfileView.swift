//
//  PlayerHighlightProfileView.swift
//  Sports
//
//  Created by Wesley St. John on 3/5/22.
//

import UIKit

class PlayerHighlightProfileView: BaseView {

    // MARK: Properties

    private let playerImageView = UIImageView()
    private let nameLabel = GlassLabel(style: .displayText1)
    private let teamImageView = UIImageView()

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

        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 8.0
        playerImageView.clipsToBounds = true
        playerImageView.layer.cornerRadius = 8.0
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(playerImageView)
        addAutoLayoutSubview(nameLabel)
        addAutoLayoutSubview(teamImageView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let playerImageSize: CGFloat = 68
        let teamImageSize = playerImageSize - (GlassSpacing.xSmall)

        NSLayoutConstraint.activate(
            playerImageView.topAnchor.constraint(equalTo: topAnchor),
            playerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            playerImageView.leftAnchor.constraint(equalTo: leftAnchor),
            playerImageView.widthAnchor.constraint(equalToConstant: playerImageSize),
            playerImageView.heightAnchor.constraint(equalToConstant: playerImageSize),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: playerImageView.rightAnchor,
                                            constant: GlassSpacing.small),
            nameLabel.rightAnchor.constraint(equalTo: teamImageView.leftAnchor,
                                            constant: -GlassSpacing.small),
            teamImageView.widthAnchor.constraint(equalToConstant: teamImageSize),
            teamImageView.heightAnchor.constraint(equalToConstant: teamImageSize),
            teamImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            teamImageView.rightAnchor.constraint(equalTo: rightAnchor,
                                                 constant: -GlassSpacing.xSmall)
        )
    }
}

extension PlayerHighlightProfileView {
    struct Model {
        var backgroundColor: UIColor = .white
        var textColor: UIColor = .black
        var playerImage: UIImage?
        var playerName: String = ""
        var teamImage: UIImage?
    }

    private func applyModel() {
        backgroundColor = model.backgroundColor
        playerImageView.image = model.playerImage
        nameLabel.text = model.playerName
        nameLabel.textColor = model.textColor
        teamImageView.image = model.teamImage
    }
}
