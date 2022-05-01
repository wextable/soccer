//
//  PlayerLevelUpViewController.swift
//  Sports
//
//  Created by Wesley St. John on 4/27/22.
//

import UIKit

protocol PlayerLevelUpViewControllerDelegate: AnyObject {
    func closeButtonTapped(_ sender: PlayerLevelUpViewController)
    func ratingSelected(_ rating: Player.Rating, sender: PlayerLevelUpViewController)
}

class PlayerLevelUpViewController: BaseViewController {

    // MARK: Properties

    weak var delegate: PlayerLevelUpViewControllerDelegate?

    private let playerRatingsViewController = PlayerRatingsViewController(model: .init())

    private let playerImageView = PixelatedImageView()
    private let stackView = UIStackView(axis: .vertical)
    private let teamContainerView = BaseView()
    private let teamImageView = UIImageView()
    private let teamLabel = GlassLabel(style: .subheading1)
    private let offensiveView = BaseView()
    private let offensiveLabel = GlassLabel(style: .body2)
    private let offensiveRatingView = FiveStarRatingView()
    private let defensiveView = BaseView()
    private let defensiveLabel = GlassLabel(style: .body2)
    private let defensiveRatingView = FiveStarRatingView()
    private let overallView = BaseView()
    private let overallLabel = GlassLabel(style: .body2)
    private let overallRatingView = FiveStarRatingView()
    private let xpView = BaseView()
    private let xpLabel = GlassLabel(style: .body2)
    private let xpRatingView = BarRatingView()

    private let instructionsContainer = BaseView()
    private let instructionsLabel = GlassLabel(style: .pageTitle)

    var model: Model { didSet { applyModel() } }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model

        super.init(nibName: nil, bundle: nil)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        stackView.distribution = .equalSpacing
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        playerRatingsViewController.delegate = self
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(playerImageView)

        teamContainerView.addAutoLayoutSubviews([
            teamImageView,
            teamLabel
        ])
        offensiveView.addAutoLayoutSubviews([
            offensiveLabel,
            offensiveRatingView
        ])
        defensiveView.addAutoLayoutSubviews([
            defensiveLabel,
            defensiveRatingView
        ])
        overallView.addAutoLayoutSubviews([
            overallLabel,
            overallRatingView
        ])
        xpView.addAutoLayoutSubviews([
            xpLabel,
            xpRatingView
        ])
        stackView.addArrangedSubviews([
            teamContainerView,
            offensiveView,
            defensiveView,
            overallView,
            xpView
        ])
        view.addAutoLayoutSubview(stackView)

        instructionsContainer.addAutoLayoutSubview(instructionsLabel)
        view.addAutoLayoutSubview(instructionsContainer)

        addAutoLayoutChild(playerRatingsViewController)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let labelWidth: CGFloat = 80.0
        let ratingWidth: CGFloat = 90.0

        NSLayoutConstraint.activate(
            playerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerImageView.widthAnchor.constraint(equalToConstant: 128),
            playerImageView.heightAnchor.constraint(equalToConstant: 128),
            playerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            teamImageView.leadingAnchor.constraint(equalTo: teamContainerView.leadingAnchor),
            teamImageView.topAnchor.constraint(equalTo: teamContainerView.topAnchor),
            teamImageView.bottomAnchor.constraint(equalTo: teamContainerView.bottomAnchor),
            teamImageView.widthAnchor.constraint(equalToConstant: 30),
            teamImageView.heightAnchor.constraint(equalToConstant: 30),
            teamLabel.centerYAnchor.constraint(equalTo: teamContainerView.centerYAnchor),
            teamLabel.leadingAnchor.constraint(equalTo: teamImageView.trailingAnchor,
                                               constant: GlassSpacing.xSmall),
            teamLabel.trailingAnchor.constraint(equalTo: teamContainerView.trailingAnchor),

            offensiveLabel.leadingAnchor.constraint(equalTo: offensiveView.leadingAnchor),
            offensiveLabel.centerYAnchor.constraint(equalTo: offensiveView.centerYAnchor),
            offensiveRatingView.leadingAnchor.constraint(equalTo: offensiveLabel.trailingAnchor,
                                                         constant: GlassSpacing.xSmall),
            offensiveRatingView.topAnchor.constraint(equalTo: offensiveView.topAnchor),
            offensiveRatingView.bottomAnchor.constraint(equalTo: offensiveView.bottomAnchor),
            offensiveRatingView.trailingAnchor.constraint(lessThanOrEqualTo: offensiveView.trailingAnchor),
            offensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),

            defensiveLabel.leadingAnchor.constraint(equalTo: defensiveView.leadingAnchor),
            defensiveLabel.centerYAnchor.constraint(equalTo: defensiveView.centerYAnchor),
            defensiveRatingView.leadingAnchor.constraint(equalTo: defensiveLabel.trailingAnchor,
                                                         constant: GlassSpacing.xSmall),
            defensiveRatingView.topAnchor.constraint(equalTo: defensiveView.topAnchor),
            defensiveRatingView.bottomAnchor.constraint(equalTo: defensiveView.bottomAnchor),
            defensiveRatingView.trailingAnchor.constraint(lessThanOrEqualTo: defensiveView.trailingAnchor),
            defensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),

            overallLabel.leadingAnchor.constraint(equalTo: overallView.leadingAnchor),
            overallLabel.centerYAnchor.constraint(equalTo: overallView.centerYAnchor),
            overallRatingView.leadingAnchor.constraint(equalTo: overallLabel.trailingAnchor,
                                                       constant: GlassSpacing.xSmall),
            overallRatingView.topAnchor.constraint(equalTo: overallView.topAnchor),
            overallRatingView.bottomAnchor.constraint(equalTo: overallView.bottomAnchor),
            overallRatingView.trailingAnchor.constraint(lessThanOrEqualTo: overallView.trailingAnchor),
            overallRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),

            xpLabel.leadingAnchor.constraint(equalTo: xpView.leadingAnchor),
            xpLabel.centerYAnchor.constraint(equalTo: xpView.centerYAnchor),
            xpRatingView.leadingAnchor.constraint(equalTo: xpLabel.trailingAnchor,
                                                  constant: GlassSpacing.xSmall),
            xpRatingView.topAnchor.constraint(equalTo: xpView.topAnchor),
            xpRatingView.bottomAnchor.constraint(equalTo: xpView.bottomAnchor),
            xpRatingView.trailingAnchor.constraint(lessThanOrEqualTo: xpView.trailingAnchor),
            xpRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),
            xpRatingView.heightAnchor.constraint(equalToConstant: 17),

            offensiveLabel.widthAnchor.constraint(equalToConstant: labelWidth),
            offensiveLabel.widthAnchor.constraint(equalTo: defensiveLabel.widthAnchor),
            defensiveLabel.widthAnchor.constraint(equalTo: overallLabel.widthAnchor),
            overallLabel.widthAnchor.constraint(equalTo: xpLabel.widthAnchor),

            stackView.topAnchor.constraint(equalTo: playerImageView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: playerImageView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: playerImageView.trailingAnchor),
            stackView.trailingAnchor.constraint(equalTo: instructionsContainer.leadingAnchor),

            instructionsContainer.topAnchor.constraint(equalTo: stackView.topAnchor),
            instructionsContainer.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            instructionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            instructionsLabel.centerXAnchor.constraint(equalTo: instructionsContainer.centerXAnchor),
            instructionsLabel.centerYAnchor.constraint(equalTo: instructionsContainer.centerYAnchor),

            playerRatingsViewController.view.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            playerRatingsViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerRatingsViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerRatingsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )
    }

    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped(self)
    }
}

extension PlayerLevelUpViewController: PlayerRatingsViewControllerDelegate {
    func ratingSelected(_ rating: Player.Rating, sender: PlayerRatingsViewController) {
        guard !model.didLevelUp else { return }
        delegate?.ratingSelected(rating, sender: self)
    }
}

extension PlayerLevelUpViewController {
    struct Model {
        var didLevelUp: Bool = false

        var title: String = ""
        var shouldShowCloseButton: Bool = true

        var teamIcon: UIImage?
        var teamName: String = ""
        var offensiveRatingOutOfFive: Double = 0
        var offensivePotentialOutOfFive: Double = 0
        var defensiveRatingOutOfFive: Double = 0
        var defensivePotentialOutOfFive: Double = 0
        var overallRatingOutOfFive: Double = 0
        var overallPotentialOutOfFive: Double = 0
        var xp: Int = 0
        var potentialXP: Int = 1
        var xpLevel: Int = 1
        var playerImage: UIImage?
        var instructions: String = ""
        var ratingsModel = PlayerRatingsViewController.Model()
    }

    private func applyModel() {
        title = model.title
        if model.shouldShowCloseButton {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done,
                                                      target: self,
                                                      action: #selector(closeButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
        }

        playerImageView.image = model.playerImage

        teamImageView.image = model.teamIcon
        teamLabel.text = model.teamName

        offensiveLabel.text = "Offense"
        offensiveRatingView.model = .init(rating: model.offensiveRatingOutOfFive,
                                          maxRating: model.offensivePotentialOutOfFive)
        defensiveLabel.text = "Defense"
        defensiveRatingView.model = .init(rating: model.defensiveRatingOutOfFive,
                                          maxRating: model.defensivePotentialOutOfFive)
        overallLabel.text = "Overall"
        overallRatingView.model = .init(rating: model.overallRatingOutOfFive,
                                        maxRating: model.overallPotentialOutOfFive)

        xpLabel.text = "XP (lvl \(model.xpLevel))"
        xpRatingView.model = .init(ratingPercent: Double(model.xp) / Double(model.potentialXP),
                                   potentialRatingPercent: 0.96) // flubbing to avoid cut-off

        instructionsLabel.text = model.instructions

        playerRatingsViewController.model = model.ratingsModel
    }
}


