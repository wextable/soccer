//
//  HighlightHUDView.swift
//  Sports
//
//  Created by Wesley St. John on 3/1/22.
//

import UIKit

class HighlightHUDView: BaseView {

    // MARK: Properties

    private let stackView = UIStackView(axis: .horizontal)
    private let awayHUDView = TeamHUDView()
    private let homeHUDView = TeamHUDView()
    private let timeLabel = UILabel()

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
        layer.cornerRadius = 3.0
        stackView.distribution = .fillProportionally
        timeLabel.textAlignment = .center
        timeLabel.font = .boldSystemFont(ofSize: 12)
        timeLabel.textColor = .black
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            awayHUDView,
            homeHUDView,
            timeLabel.paddedContainer(insets: .init(top: .zero, leading: GlassSpacing.xxSmall,
                                                    bottom: .zero, trailing: GlassSpacing.xxSmall))
        ])

        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            timeLabel.widthAnchor.constraint(equalToConstant: 30.0),
            stackView.constraints(pinningTo: self)
        )
    }
}

extension HighlightHUDView {
    struct Model {
        var awayTeamModel: TeamHUDView.Model = .init()
        var homeTeamModel: TeamHUDView.Model = .init()
        var timeText: String = ""
    }

    private func applyModel() {
        awayHUDView.model = model.awayTeamModel
        homeHUDView.model = model.homeTeamModel
        timeLabel.text = model.timeText
    }
}
