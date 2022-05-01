//
//  GameSummaryViewController.swift
//  Sports
//
//  Created by Wesley St. John on 2/26/22.
//

import UIKit

protocol GameSummaryViewControllerDelegate: AnyObject {
    func playerSelected(withID id: String, sender: GameSummaryViewController)
    func playGameButtonTapped(_ sender: GameSummaryViewController)
    func hightlightsButtonTapped(_ sender: GameSummaryViewController)
    func dismiss(_ sender: GameSummaryViewController)
}

class GameSummaryViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: GameSummaryViewControllerDelegate?

    private let stackView = UIStackView(axis: .vertical)

    private let topStackView = UIStackView(axis: .horizontal)
    private let awayImageView = UIImageView()

    private let middleStackView = UIStackView(axis: .vertical)
    private let teamNamesContainer = BaseView()
    private let awayNameLabel = GlassLabel(style: .heading)
    private let homeNameLabel = GlassLabel(style: .heading)

    private let offensiveRatingsContainer = BaseView()
    private let awayOffensiveLabel = GlassLabel(style: .body2)
    private let awayOffensiveRatingView = FiveStarRatingView()
    private let homeOffensiveLabel = GlassLabel(style: .body2)
    private let homeOffensiveRatingView = FiveStarRatingView()

    private let defensiveRatingsContainer = BaseView()
    private let awayDefensiveLabel = GlassLabel(style: .body2)
    private let awayDefensiveRatingView = FiveStarRatingView()
    private let homeDefensiveRatingView = FiveStarRatingView()
    private let homeDefensiveLabel = GlassLabel(style: .body2)

    private let seasonStatsContainer = BaseView()
    private let awaySeasonStatsLabel = GlassLabel(style: .body2)
    private let homeSeasonStatsLabel = GlassLabel(style: .body2)

    private let scoreLabel = UILabel()

    private let homeImageView = UIImageView()

    // ------------

    private let gamePreviewView = BaseView()
    private let playerCardsContainer = BaseView()
    private let playerCardsLabel = GlassLabel(style: .body1)
    private let awayCardsController = PlayerCardViewController()
    private let homeCardsController = PlayerCardViewController()

    // ------------

    private let gameStatsView = BaseView()
    private let goalsContainer = BaseView()
    private let awayGoalsLabel = GlassLabel(style: .body2)
    private let homeGoalsLabel = GlassLabel(style: .body2)

    // ------------

    private let buttonContainer = BaseView()
    private let playGameButton = GlassPrimaryButton(buttonStyle: .large)
    private let highlightsButton = GlassPrimaryButton(buttonStyle: .large)

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        stackView.distribution = .equalCentering

        topStackView.distribution = .fill
        topStackView.spacing = GlassSpacing.small
        middleStackView.distribution = .fillProportionally
        awayNameLabel.textAlignment = .right
        awayNameLabel.adjustsFontSizeToFitWidth = true
        awayNameLabel.minimumScaleFactor = 0.5
        homeNameLabel.adjustsFontSizeToFitWidth = true
        homeNameLabel.minimumScaleFactor = 0.5
        awayOffensiveLabel.textAlignment = .right
        awayDefensiveLabel.textAlignment = .right
        awaySeasonStatsLabel.textAlignment = .right
        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 40, weight: .black)
        scoreLabel.textColor = GlassColor.gray160.uiColor

        playerCardsContainer.backgroundColor = GlassColor.gray40.uiColor
        playerCardsLabel.textAlignment = .center
        awayCardsController.delegate = self
        homeCardsController.delegate = self

        awayGoalsLabel.textAlignment = .right
        awayGoalsLabel.numberOfLines = 0
        homeGoalsLabel.numberOfLines = 0

        playGameButton.setTitle("Play game", for: .normal)
        playGameButton.addTarget(self, action: #selector(playGameButtonTapped), for: .touchUpInside)
        highlightsButton.setTitle("Watch highlights", for: .normal)
        highlightsButton.addTarget(self, action: #selector(hightlightsButtonTapped), for: .touchUpInside)
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        teamNamesContainer.addAutoLayoutSubviews([
            awayNameLabel,
            homeNameLabel
        ])

        offensiveRatingsContainer.addAutoLayoutSubviews([
            awayOffensiveLabel,
            awayOffensiveRatingView,
            homeOffensiveLabel,
            homeOffensiveRatingView
        ])

        defensiveRatingsContainer.addAutoLayoutSubviews([
            awayDefensiveLabel,
            awayDefensiveRatingView,
            homeDefensiveLabel,
            homeDefensiveRatingView
        ])

        seasonStatsContainer.addAutoLayoutSubviews([
            awaySeasonStatsLabel,
            homeSeasonStatsLabel
        ])

        middleStackView.addArrangedSubviews([
            teamNamesContainer,
            offensiveRatingsContainer,
            defensiveRatingsContainer,
            seasonStatsContainer,
            scoreLabel
        ])

        topStackView.addArrangedSubviews([
            awayImageView,
            middleStackView,
            homeImageView
        ])

        playerCardsContainer.addAutoLayoutSubview(playerCardsLabel)
        addChild(awayCardsController)
        playerCardsContainer.addAutoLayoutSubview(awayCardsController.view)
        awayCardsController.didMove(toParent: self)
        addChild(homeCardsController)
        playerCardsContainer.addAutoLayoutSubview(homeCardsController.view)
        homeCardsController.didMove(toParent: self)
        gamePreviewView.addAutoLayoutSubviews([
            playerCardsContainer
        ])

        goalsContainer.addAutoLayoutSubviews([
            awayGoalsLabel,
            homeGoalsLabel
        ])
        gameStatsView.addAutoLayoutSubviews([
            goalsContainer
        ])

        buttonContainer.addAutoLayoutSubviews([
            playGameButton,
            highlightsButton
        ])

        stackView.addArrangedSubviews([
            topStackView,
            gamePreviewView,
            gameStatsView,
            buttonContainer
        ])

        view.addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let iconSize: CGFloat = UIScreen.main.bounds.height * 0.25
        let ratingWidth: CGFloat = 90.0
        NSLayoutConstraint.activate(
            awayImageView.widthAnchor.constraint(equalToConstant: iconSize),
            awayImageView.heightAnchor.constraint(equalToConstant: iconSize),
            awayImageView.topAnchor.constraint(equalTo: topStackView.topAnchor),
            awayImageView.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor),

            awayNameLabel.topAnchor.constraint(equalTo: teamNamesContainer.topAnchor),
            awayNameLabel.bottomAnchor.constraint(equalTo: teamNamesContainer.bottomAnchor),
            awayNameLabel.leadingAnchor.constraint(equalTo: teamNamesContainer.leadingAnchor),
            homeNameLabel.leadingAnchor.constraint(equalTo: awayNameLabel.trailingAnchor,
                                                   constant: GlassSpacing.small),
            homeNameLabel.trailingAnchor.constraint(equalTo: teamNamesContainer.trailingAnchor),
            homeNameLabel.topAnchor.constraint(equalTo: teamNamesContainer.topAnchor),
            homeNameLabel.bottomAnchor.constraint(equalTo: teamNamesContainer.bottomAnchor),
            homeNameLabel.widthAnchor.constraint(equalTo: awayNameLabel.widthAnchor),

            awayOffensiveLabel.topAnchor.constraint(equalTo: offensiveRatingsContainer.topAnchor),
            awayOffensiveLabel.bottomAnchor.constraint(equalTo: offensiveRatingsContainer.bottomAnchor),
            awayOffensiveRatingView.leadingAnchor.constraint(equalTo: awayOffensiveLabel.trailingAnchor,
                                                             constant: GlassSpacing.xxSmall),
            awayOffensiveRatingView.trailingAnchor.constraint(equalTo: offensiveRatingsContainer.centerXAnchor,
                                                             constant: -GlassSpacing.xSmall),
            awayOffensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),
            awayOffensiveRatingView.centerYAnchor.constraint(equalTo: offensiveRatingsContainer.centerYAnchor),

            homeOffensiveLabel.leadingAnchor.constraint(equalTo: awayOffensiveRatingView.trailingAnchor,
                                                             constant: GlassSpacing.small),
            homeOffensiveLabel.centerYAnchor.constraint(equalTo: offensiveRatingsContainer.centerYAnchor),
            homeOffensiveRatingView.leadingAnchor.constraint(equalTo: homeOffensiveLabel.trailingAnchor,
                                                             constant: GlassSpacing.xxSmall),
            homeOffensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),
            homeOffensiveRatingView.centerYAnchor.constraint(equalTo: offensiveRatingsContainer.centerYAnchor),

            awayDefensiveLabel.topAnchor.constraint(equalTo: defensiveRatingsContainer.topAnchor),
            awayDefensiveLabel.bottomAnchor.constraint(equalTo: defensiveRatingsContainer.bottomAnchor),
            awayDefensiveRatingView.leadingAnchor.constraint(equalTo: awayDefensiveLabel.trailingAnchor,
                                                             constant: GlassSpacing.xxSmall),
            awayDefensiveRatingView.trailingAnchor.constraint(equalTo: defensiveRatingsContainer.centerXAnchor,
                                                              constant: -GlassSpacing.xSmall),
            awayDefensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),
            awayDefensiveRatingView.centerYAnchor.constraint(equalTo: defensiveRatingsContainer.centerYAnchor),

            homeDefensiveLabel.leadingAnchor.constraint(equalTo: awayDefensiveRatingView.trailingAnchor,
                                                        constant: GlassSpacing.small),
            homeDefensiveLabel.centerYAnchor.constraint(equalTo: defensiveRatingsContainer.centerYAnchor),
            homeDefensiveRatingView.leadingAnchor.constraint(equalTo: homeDefensiveLabel.trailingAnchor,
                                                             constant: GlassSpacing.xxSmall),
            homeDefensiveRatingView.widthAnchor.constraint(equalToConstant: ratingWidth),
            homeDefensiveRatingView.centerYAnchor.constraint(equalTo: defensiveRatingsContainer.centerYAnchor),

            awaySeasonStatsLabel.topAnchor.constraint(equalTo: seasonStatsContainer.topAnchor),
            awaySeasonStatsLabel.bottomAnchor.constraint(equalTo: seasonStatsContainer.bottomAnchor),
            awaySeasonStatsLabel.leadingAnchor.constraint(equalTo: seasonStatsContainer.leadingAnchor),
            homeSeasonStatsLabel.leadingAnchor.constraint(equalTo: awaySeasonStatsLabel.trailingAnchor,
                                                          constant: GlassSpacing.small),
            homeSeasonStatsLabel.trailingAnchor.constraint(equalTo: seasonStatsContainer.trailingAnchor),
            homeSeasonStatsLabel.topAnchor.constraint(equalTo: seasonStatsContainer.topAnchor),
            homeSeasonStatsLabel.bottomAnchor.constraint(equalTo: seasonStatsContainer.bottomAnchor),
            homeSeasonStatsLabel.widthAnchor.constraint(equalTo: awaySeasonStatsLabel.widthAnchor),

            homeImageView.widthAnchor.constraint(equalToConstant: iconSize),
            homeImageView.heightAnchor.constraint(equalToConstant: iconSize),
            homeImageView.topAnchor.constraint(equalTo: topStackView.topAnchor),
            homeImageView.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor),

            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),

            playerCardsLabel.topAnchor.constraint(equalTo: playerCardsContainer.topAnchor,
                                                  constant: GlassSpacing.xxSmall),
            playerCardsLabel.leadingAnchor.constraint(equalTo: playerCardsContainer.leadingAnchor),
            playerCardsLabel.trailingAnchor.constraint(equalTo: playerCardsContainer.trailingAnchor),

            awayCardsController.view.topAnchor.constraint(equalTo: playerCardsLabel.bottomAnchor,
                                                          constant: -GlassSpacing.xxSmall),
            awayCardsController.view.bottomAnchor.constraint(equalTo: playerCardsContainer.bottomAnchor),
            awayCardsController.view.leadingAnchor.constraint(equalTo: playerCardsContainer.leadingAnchor),
            awayCardsController.view.trailingAnchor.constraint(equalTo: playerCardsContainer.centerXAnchor,
                                                               constant: -GlassSpacing.xSmall),
            homeCardsController.view.topAnchor.constraint(equalTo: playerCardsLabel.bottomAnchor),
            homeCardsController.view.bottomAnchor.constraint(equalTo: playerCardsContainer.bottomAnchor),
            homeCardsController.view.leadingAnchor.constraint(equalTo: playerCardsContainer.centerXAnchor,
                                                              constant: GlassSpacing.xSmall),
            homeCardsController.view.trailingAnchor.constraint(equalTo: playerCardsContainer.trailingAnchor),

            playerCardsContainer.constraints(pinningTo: gamePreviewView),

            gamePreviewView.topAnchor.constraint(equalTo: topStackView.bottomAnchor),
            gamePreviewView.bottomAnchor.constraint(equalTo: playGameButton.topAnchor),
            gamePreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gamePreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            awayGoalsLabel.topAnchor.constraint(equalTo: goalsContainer.topAnchor),
            awayGoalsLabel.bottomAnchor.constraint(equalTo: goalsContainer.bottomAnchor),
            awayGoalsLabel.leadingAnchor.constraint(equalTo: goalsContainer.leadingAnchor),
            homeGoalsLabel.leadingAnchor.constraint(equalTo: awayGoalsLabel.trailingAnchor,
                                                   constant: GlassSpacing.small),
            homeGoalsLabel.trailingAnchor.constraint(equalTo: goalsContainer.trailingAnchor),
            homeGoalsLabel.topAnchor.constraint(equalTo: goalsContainer.topAnchor),
            homeGoalsLabel.bottomAnchor.constraint(equalTo: goalsContainer.bottomAnchor),
            homeGoalsLabel.widthAnchor.constraint(equalTo: awayGoalsLabel.widthAnchor),

            goalsContainer.constraints(pinningTo: gameStatsView),

            playGameButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            playGameButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor,
                                                constant: GlassSpacing.xxSmall),
            playGameButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor,
                                                   constant: -GlassSpacing.small),
            playGameButton.widthAnchor.constraint(equalToConstant: 160),
            playGameButton.heightAnchor.constraint(equalToConstant: 40),

            highlightsButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            highlightsButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor,
                                                constant: GlassSpacing.xxSmall),
            highlightsButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor,
                                                   constant: -GlassSpacing.small),
            highlightsButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            highlightsButton.widthAnchor.constraint(equalToConstant: 160),
            highlightsButton.heightAnchor.constraint(equalToConstant: 40),

            stackView.constraints(pinningTo: view)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if model.shouldAutoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.delegate?.dismiss(self)
            }
        }
    }

    @objc func playGameButtonTapped() {
        delegate?.playGameButtonTapped(self)
    }

    @objc func hightlightsButtonTapped() {
        delegate?.hightlightsButtonTapped(self)
    }

    @objc func dismissView() {
        if model.shouldAutoDismiss {
            delegate?.dismiss(self)
        }
    }
}

extension GameSummaryViewController: PlayerCardViewControllerDelegate {
    func playerSelected(withID id: String, sender: PlayerCardViewController) {
        delegate?.playerSelected(withID: id, sender: self)
    }
}

extension GameSummaryViewController {
    struct Model {
        var title: String = ""

        var awayLogo: UIImage?
        var awayName: String = ""
        var homeName: String = ""
        var awayOffRatingOutOfFive: Double?
        var homeOffRatingOutOfFive: Double?
        var awayDefRatingOutOfFive: Double?
        var homeDefRatingOutOfFive: Double?
        var awaySeasonStats: String?
        var homeSeasonStats: String?
        var homeLogo: UIImage?

        var awayPlayerCardModels: [PlayerCardView.Model] = []
        var homePlayerCardModels: [PlayerCardView.Model] = []

        var score: String?

        var awayGoalsText: String?
        var homeGoalsText: String?

        var shouldShowPlayGameButton: Bool = false
        var shouldShowHighlightsButton: Bool = false
        var shouldAutoDismiss: Bool = false
    }

    private func applyModel() {
        title = model.title

        awayImageView.image = model.awayLogo
        awayNameLabel.text = model.awayName
        homeNameLabel.text = model.homeName

        if let awayOffRating = model.awayOffRatingOutOfFive,
           let homeOffRating = model.homeOffRatingOutOfFive,
           let awayDefRating = model.awayDefRatingOutOfFive,
           let homeDefRating = model.homeDefRatingOutOfFive {
            awayOffensiveLabel.text = "Offense"
            awayOffensiveRatingView.model = .init(rating: awayOffRating,
                                                  maxRating: awayOffRating)
            homeOffensiveLabel.text = "Offense"
            homeOffensiveRatingView.model = .init(rating: homeOffRating,
                                                  maxRating: homeOffRating)
            awayDefensiveLabel.text = "Defense"
            awayDefensiveRatingView.model = .init(rating: awayDefRating,
                                                  maxRating: awayDefRating)
            homeDefensiveLabel.text = "Defense"
            homeDefensiveRatingView.model = .init(rating: homeDefRating,
                                                  maxRating: homeDefRating)

            offensiveRatingsContainer.isHidden = false
            defensiveRatingsContainer.isHidden = false
        } else {
            offensiveRatingsContainer.isHidden = true
            defensiveRatingsContainer.isHidden = true
        }

        awaySeasonStatsLabel.text = model.awaySeasonStats
        homeSeasonStatsLabel.text = model.homeSeasonStats
        seasonStatsContainer.isHidden = (model.awaySeasonStats == nil) || (model.homeSeasonStats == nil)

        homeImageView.image = model.homeLogo

        playerCardsLabel.text = "Key Players"
        awayCardsController.model = .init(playerCardModels: model.awayPlayerCardModels)
        homeCardsController.model = .init(playerCardModels: model.homePlayerCardModels)
        gamePreviewView.isHidden = (model.awayGoalsText != nil) && (model.homeGoalsText != nil)

        scoreLabel.text = model.score
        scoreLabel.isHidden = model.score == nil

        awayGoalsLabel.text = model.awayGoalsText
        homeGoalsLabel.text = model.homeGoalsText
        gameStatsView.isHidden = (model.awayGoalsText == nil) || (model.homeGoalsText == nil)

        highlightsButton.isHidden = !model.shouldShowHighlightsButton
        playGameButton.isHidden = !model.shouldShowPlayGameButton
        buttonContainer.isHidden = !model.shouldShowHighlightsButton && !model.shouldShowPlayGameButton
    }
}
