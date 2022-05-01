//
//  PlayerListingView.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

protocol PlayerListingViewDelegate: AnyObject {
    func checkboxToggled(isSelected: Bool, sender: PlayerListingView)
}

class PlayerListingView: BaseView {

    // MARK: Properties

    weak var delegate: PlayerListingViewDelegate?

    private let stackView = UIStackView(axis: .horizontal)
    private let checkboxContainer = BaseView()
    private let checkbox = CheckboxView()
    private let positionLabel = GlassLabel(style: .body2)
    private let nameLabel = GlassLabel(style: .body2)
    private let statusIconContainer = BaseView()
    private let statusIcon = UIImageView()
    // morale
    private let conditionLabel = GlassLabel(style: .body2)
    private let overallLabel = GlassLabel(style: .body2)
    private let ratingContainer = BaseView()
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
        checkbox.addTarget(self, action: #selector(checkboxTapped(sender:)),
                           for: .touchUpInside)
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.clipsToBounds = true
        statusIcon.layer.cornerRadius = 3.0
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        checkboxContainer.addAutoLayoutSubview(checkbox)
        ratingContainer.addAutoLayoutSubview(overallRatingView)
        statusIconContainer.addAutoLayoutSubview(statusIcon)
        stackView.addArrangedSubviews([
            checkboxContainer,
            positionLabel,
            nameLabel,
            statusIconContainer,
            conditionLabel,
            overallLabel,
            ratingContainer,
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

        let height = 22.0
        let standardWidth = 33.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0)),
            checkboxContainer.widthAnchor.constraint(equalToConstant: 42),
            checkbox.topAnchor.constraint(equalTo: checkboxContainer.topAnchor),
            checkbox.bottomAnchor.constraint(equalTo: checkboxContainer.bottomAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: height),
            checkbox.centerXAnchor.constraint(equalTo: checkboxContainer.centerXAnchor),
            positionLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            statusIconContainer.widthAnchor.constraint(equalToConstant: height),
            statusIconContainer.widthAnchor.constraint(equalTo: statusIconContainer.heightAnchor),
            statusIcon.topAnchor.constraint(equalTo: statusIconContainer.topAnchor,
                                                constant: GlassSpacing.xxSmall),
            statusIcon.leadingAnchor.constraint(equalTo: statusIconContainer.leadingAnchor,
                                                constant: GlassSpacing.xxSmall),
            statusIcon.centerXAnchor.constraint(equalTo: statusIconContainer.centerXAnchor),
            statusIcon.centerYAnchor.constraint(equalTo: statusIconContainer.centerYAnchor),
            conditionLabel.widthAnchor.constraint(equalToConstant: 40),
            overallRatingView.widthAnchor.constraint(equalToConstant: 120),
            overallRatingView.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            overallRatingView.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor),
            overallRatingView.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            overallLabel.widthAnchor.constraint(equalToConstant: 120),
            offenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            defenseLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            goalsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            assistsLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            savesLabel.widthAnchor.constraint(equalToConstant: standardWidth),
            cleanSheetsLabel.widthAnchor.constraint(equalToConstant: standardWidth)
        )
    }

    @objc private func checkboxTapped(sender: CheckboxView) {
        delegate?.checkboxToggled(isSelected: sender.isSelected, sender: self)
    }
}

extension PlayerListingView {
    struct Model: Hashable {
        var id: String = ""
        var isCheckboxHidden: Bool = false
        var isCheckboxEnabled: Bool = false
        var isCheckboxSelected: Bool = false
        var position: String = ""
        var positionColor: UIColor = GlassColor.gray140.uiColor
        var name: String = ""
        var statusIcon: UIImage?
        var condition: String = ""
        var conditionColor: UIColor = GlassColor.gray140.uiColor
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
        checkboxContainer.isHidden = model.isCheckboxHidden
        checkbox.isUserInteractionEnabled = model.isCheckboxEnabled
        checkbox.isSelected = model.isCheckboxSelected
        positionLabel.text = model.position
        positionLabel.textColor = model.positionColor
        nameLabel.text = model.name
        statusIcon.image = model.statusIcon
        conditionLabel.text = model.condition
        conditionLabel.textColor = model.conditionColor

        if let overallText = model.overallText {
            overallLabel.text = overallText
            overallLabel.isHidden = false
            ratingContainer.isHidden = true
        } else if let overallRatingOutOfFive = model.overallRatingOutOfFive,
                  let overallPotentialOutOfFive = model.overallPotentialOutOfFive {
            overallLabel.isHidden = true
            overallRatingView.model = .init(rating: overallRatingOutOfFive,
                                            maxRating: overallPotentialOutOfFive)
            ratingContainer.isHidden = false
        }

        offenseLabel.text = model.offense
        defenseLabel.text = model.defense
        goalsLabel.text = model.goals
        assistsLabel.text = model.assists
        savesLabel.text = model.saves
        cleanSheetsLabel.text = model.cleanSheets
    }
}

