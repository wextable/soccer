//
//  PlayerViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/29/21.
//

import UIKit

protocol PlayerViewControllerDelegate: AnyObject {
    func closeButtonTapped(_ sender: PlayerViewController)
    func testing_upgradeRating(_ rating: Player.Rating)
}

class PlayerViewController: BaseViewController {

    // MARK: Properties

    weak var delegate: PlayerViewControllerDelegate?

    private let segmentedControl: UISegmentedControl
    private let playerRatingsViewController = PlayerRatingsViewController(model: .init())
//    private let teamScheduleViewController = TeamScheduleViewController(model: .init())

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

//    private let positionLabel = GlassLabel(style: .body2)
//    private let ageLabel = GlassLabel(style: .body2)
//    private let heightLabel = GlassLabel(style: .body2)
//    private let weightLabel = GlassLabel(style: .body2)
//    private let contractLabel = GlassLabel(style: .body2)

//    private let overallLabel = GlassLabel(style: .body2)

//    private let goalsLabel = GlassLabel(style: .body2)
//    private let assistsLabel = GlassLabel(style: .body2)
//    private let savesLabel = GlassLabel(style: .body2)
//    private let cleanSheetsLabel = GlassLabel(style: .body2)

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        segmentedControl = UISegmentedControl(items: model.segments.map { $0.title })
        segmentedControl.selectedSegmentIndex = 0

        super.init(nibName: nil, bundle: nil)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        stackView.distribution = .equalSpacing
//        stackView.spacing = GlassSpacing.xSmall
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)

        playerRatingsViewController.delegate = self
//        playerRatingsViewController.delegate = self
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
//            paddedContainer(ageLabel),
//            paddedContainer(heightLabel),
//            paddedContainer(weightLabel),
//            paddedContainer(contractLabel),
//            paddedContainer(overallLabel),
//            paddedContainer(goalsLabel),
//            paddedContainer(assistsLabel),
//            paddedContainer(savesLabel),
//            paddedContainer(cleanSheetsLabel)
        ])
        view.addAutoLayoutSubview(stackView)

        view.addAutoLayoutSubview(segmentedControl)
        addAutoLayoutChild(playerRatingsViewController)
//        addAutoLayoutChild(teamScheduleViewController)
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
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            segmentedControl.topAnchor.constraint(equalTo: playerImageView.bottomAnchor,
                                                  constant: GlassSpacing.xSmall),
            segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerRatingsViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            playerRatingsViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerRatingsViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerRatingsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            teamScheduleViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
//            teamScheduleViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
//            teamScheduleViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
//            teamScheduleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )
    }

    @objc private func segmentedValueChanged(_ sender: UISegmentedControl) {
        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
        updateSegment()
    }

    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped(self)
    }
}

extension PlayerViewController {
    private func updateSegment() {
        playerRatingsViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .ratings
//        teamScheduleViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .teamSchedule
    }
}

extension PlayerViewController: PlayerRatingsViewControllerDelegate {
    func ratingSelected(_ rating: Player.Rating, sender: PlayerRatingsViewController) {
        delegate?.testing_upgradeRating(rating)
    }
}

extension PlayerViewController {
    struct Model {

        enum Segment: Equatable {
            case ratings
//            case teamSchedule

            var title: String {
                switch self {
                case .ratings: return "Ratings"
//                case .teamSchedule: return "Schedule"
                }
            }
        }

        var title: String = ""
        var shouldShowCloseButton: Bool = false

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

        var position: String = ""
        var age: String = ""
        var height: String = ""
        var weight: String = ""
        var playerImage: UIImage?
        var contract: String = ""
        var overall: String = ""
        var goals: String = ""
        var assists: String = ""
        var saves: String = ""
        var cleanSheets: String = ""

        // morale
        // condition
        // jersey number
        // is captain

        var segments: [Segment] = []
        var ratingsModel = PlayerRatingsViewController.Model()
//        var teamScheduleModel = TeamScheduleViewController.Model()
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

        //        positionLabel.text = model.position
        //        ageLabel.text = model.age
        //        heightLabel.text = model.height
        //        weightLabel.text = model.weight
        //        contractLabel.text = model.contract
        //        overallLabel.text = model.overall
        //        goalsLabel.text = model.goals
        //        assistsLabel.text = model.assists
        //        savesLabel.text = model.saves
        //        cleanSheetsLabel.text = model.cleanSheets

        for i in 0..<model.segments.count {
            segmentedControl.setTitle(model.segments[i].title, forSegmentAt: i)
        }
        playerRatingsViewController.model = model.ratingsModel
//        teamScheduleViewController.model = model.teamScheduleModel

        updateSegment()
    }
}

