//
//  TeamSelectionView.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import UIKit

class TeamSelectionView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let teamIcon = UIImageView()
    private let nameLabel = GlassLabel(style: .body2)
    private let prestigeLabel = GlassLabel(style: .body2)

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
        prestigeLabel.textAlignment = .center
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            teamIcon.paddedContainer(),
            nameLabel,
            prestigeLabel
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let iconSize: CGFloat = 40
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            teamIcon.widthAnchor.constraint(equalToConstant: iconSize),
            teamIcon.heightAnchor.constraint(equalToConstant: iconSize),
            prestigeLabel.widthAnchor.constraint(equalToConstant: 120)
        )
    }
}

extension TeamSelectionView {
    struct Model: Hashable {
        var id: String = ""
        var image: UIImage?
        var name: String = ""
        var prestige: String = ""
    }

    private func applyModel() {
        teamIcon.image = model.image
        nameLabel.text = model.name
        prestigeLabel.text = model.prestige
    }
}
