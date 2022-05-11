//
//  TeamViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit
import CloudKit

protocol TeamViewControllerDelegate: AnyObject {
    func playerSelected(withId id: String, sender: TeamViewController)
    func player(withId id: String,
                startingToggled isStarting: Bool,
                sender: TeamViewController)
    func myLeagueSelected(_ sender: TeamViewController)
    func playGameSelected(_ sender: TeamViewController)
    func gameSelected(withId id: String, sender: TeamViewController)
}

class TeamViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: TeamViewControllerDelegate?

    private let segmentedControl: UISegmentedControl
    private let teamRosterViewController = TeamRosterViewController(model: .init())
    private let teamScheduleViewController = TeamScheduleViewController(model: .init())

    private let stackView = UIStackView(axis: .horizontal)
    private let imageView = UIImageView()
    private let midStackView = UIStackView(axis: .vertical)
    private let recordLabel = GlassLabel(style: .body2)
    private let offenseView = BaseView()
    private let offenseLabel = GlassLabel(style: .body2)
    private let offensiveRatingView = FiveStarRatingView()
    private let defenseView = BaseView()
    private let defenseLabel = GlassLabel(style: .body2)
    private let defensiveRatingView = FiveStarRatingView()
    private let rightStackView = UIStackView(axis: .vertical)
    private let opponentLabel = GlassLabel(style: .body2)
    private let playGameButtonContainer = UIView()
    private let playGameButton = GlassPrimaryButton(buttonStyle: GlassButtonStyle.large)

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

        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        stackView.spacing = GlassSpacing.small
        stackView.distribution = .fillProportionally
        midStackView.distribution = .fillProportionally
        rightStackView.distribution = .fillProportionally

        offenseLabel.text = "Offense"
        defenseLabel.text = "Defense"

        opponentLabel.textAlignment = .center
        opponentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        opponentLabel.setContentHuggingPriority(.required, for: .horizontal)

        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)

        playGameButton.setTitle("Play game", for: .normal)
        playGameButton.addTarget(self, action: #selector(playGameTapped), for: .touchUpInside)

        teamRosterViewController.delegate = self
        teamScheduleViewController.delegate = self
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        offenseView.addAutoLayoutSubviews([
            offenseLabel,
            offensiveRatingView
        ])
        defenseView.addAutoLayoutSubviews([
            defenseLabel,
            defensiveRatingView
        ])
        midStackView.addArrangedSubviews([
            recordLabel,
            offenseView,
            defenseView
        ])
        playGameButtonContainer.addAutoLayoutSubview(playGameButton)
        rightStackView.addArrangedSubviews([
            opponentLabel,
            playGameButtonContainer
        ])
        stackView.addArrangedSubviews([
            imageView,
            midStackView,
            rightStackView
        ])
        view.addAutoLayoutSubview(stackView)
        view.addAutoLayoutSubview(segmentedControl)
        addAutoLayoutChild(teamRosterViewController)
        addAutoLayoutChild(teamScheduleViewController)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let imageSize: CGFloat = 80
        NSLayoutConstraint.activate(
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: GlassSpacing.medium),
            stackView.heightAnchor.constraint(equalToConstant: imageSize),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GlassSpacing.small),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -GlassSpacing.xSmall),
            imageView.widthAnchor.constraint(equalToConstant: imageSize),
            imageView.heightAnchor.constraint(equalToConstant: imageSize),
            offenseLabel.constraints(pinningTo: offenseView, edges: [.vertical, .leading]),
            offenseLabel.trailingAnchor.constraint(equalTo: offensiveRatingView.leadingAnchor,
                                                   constant: -GlassSpacing.xSmall),
            offensiveRatingView.widthAnchor.constraint(equalToConstant: 120),
            offensiveRatingView.constraints(pinningTo: offenseView, edges: [.vertical]),
            offensiveRatingView.trailingAnchor.constraint(lessThanOrEqualTo: offenseView.trailingAnchor,
                                                          constant: -GlassSpacing.xSmall),
            defenseLabel.constraints(pinningTo: defenseView, edges: [.vertical, .leading]),
            defenseLabel.trailingAnchor.constraint(equalTo: defensiveRatingView.leadingAnchor,
                                                   constant: -GlassSpacing.xSmall),
            defensiveRatingView.widthAnchor.constraint(equalToConstant: 120),
            defensiveRatingView.constraints(pinningTo: defenseView, edges: [.vertical]),
            defensiveRatingView.trailingAnchor.constraint(lessThanOrEqualTo: defenseView.trailingAnchor,
                                                          constant: -GlassSpacing.xSmall),
            offenseLabel.widthAnchor.constraint(equalTo: defenseLabel.widthAnchor),
            playGameButton.topAnchor.constraint(equalTo: playGameButtonContainer.topAnchor),
            playGameButton.widthAnchor.constraint(equalToConstant: 160),
            playGameButton.centerXAnchor.constraint(equalTo: playGameButtonContainer.centerXAnchor),
            playGameButtonContainer.widthAnchor.constraint(greaterThanOrEqualTo: playGameButton.widthAnchor),
            playGameButtonContainer.widthAnchor.constraint(greaterThanOrEqualTo: opponentLabel.widthAnchor),
            playGameButtonContainer.heightAnchor.constraint(equalTo: playGameButton.heightAnchor),
            segmentedControl.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: GlassSpacing.xSmall),
            segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor),
            teamRosterViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            teamRosterViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            teamRosterViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            teamRosterViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            teamScheduleViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            teamScheduleViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            teamScheduleViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            teamScheduleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModel()
    }

    @objc private func segmentedValueChanged(_ sender: UISegmentedControl) {
        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
        updateSegment()
    }

    @objc private func myLeagueTapped() {
        delegate?.myLeagueSelected(self)
    }

    @objc private func playGameTapped() {
        delegate?.playGameSelected(self)
    }
}

extension TeamViewController {
    private func updateSegment() {
        teamRosterViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .teamRoster
        teamScheduleViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .teamSchedule
    }
}

extension TeamViewController: TeamRosterViewControllerDelegate {
    func playerSelected(withId id: String, sender: TeamRosterViewController) {
        delegate?.playerSelected(withId: id, sender: self)
    }

    func player(withId id: String,
                startingToggled isStarting: Bool,
                sender: TeamRosterViewController) {
        delegate?.player(withId: id,
                         startingToggled: isStarting,
                         sender: self)
    }
}

extension TeamViewController: TeamScheduleViewControllerDelegate {
    func gameSelected(withId id: String, sender: TeamScheduleViewController) {
        delegate?.gameSelected(withId: id, sender: self)
    }
}

extension TeamViewController {
    struct Model {

        enum Segment: Equatable {
            case teamRoster
            case teamSchedule

            var title: String {
                switch self {
                case .teamRoster: return "Roster"
                case .teamSchedule: return "Schedule"
                }
            }
        }

        var teamId: String = ""
        var title: String = ""
        var icon: UIImage?
        var record: String = ""
        var offensiveRatingOutOfFive: Double?
        var offensivePotentialOutOfFive: Double?
        var defensiveRatingOutOfFive: Double?
        var defensivePotentialOutOfFive: Double?
        var opponentString: NSAttributedString?
        var isUserTeam: Bool = false

        var segments: [Segment] = []
        var teamRosterModel = TeamRosterViewController.Model()
        var teamScheduleModel = TeamScheduleViewController.Model()
    }

    private func applyModel() {
        title = model.title
        if model.isUserTeam {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "My League",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(myLeagueTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
        }

        imageView.image = model.icon
        recordLabel.text = model.record

        if let offensiveRatingOutOfFive = model.offensiveRatingOutOfFive,
           let offensivePotentialOutOfFive = model.offensivePotentialOutOfFive,
           let defensiveRatingOutOfFive = model.defensiveRatingOutOfFive,
           let defensivePotentialOutOfFive = model.defensivePotentialOutOfFive {
            offensiveRatingView.model = .init(rating: offensiveRatingOutOfFive,
                                              maxRating: offensivePotentialOutOfFive)
            defensiveRatingView.model = .init(rating: defensiveRatingOutOfFive,
                                              maxRating: defensivePotentialOutOfFive)
        }

        opponentLabel.attributedText = model.opponentString
        playGameButtonContainer.isHidden = !model.isUserTeam || model.opponentString == nil

        for i in 0..<model.segments.count {
            segmentedControl.setTitle(model.segments[i].title, forSegmentAt: i)
        }
        teamRosterViewController.model = model.teamRosterModel
        teamScheduleViewController.model = model.teamScheduleModel

        updateSegment()
    }
}
