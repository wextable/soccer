//
//  LeagueViewController.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit
import CloudKit

protocol LeagueViewControllerDelegate: AnyObject {
    func teamSelected(withId id: String, sender: LeagueViewController)
    func playerSelected(withId id: String, sender: LeagueViewController)
    func gameSelected(withId id: String, sender: LeagueViewController)
    func simulateWeek(sender: LeagueViewController)
    func openDebugMenu(_ sender: LeagueViewController)
}

class LeagueViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: LeagueViewControllerDelegate?

    let segmentedControl: UISegmentedControl
    let leagueStandingsViewController = LeagueStandingsViewController(model: .init())
    let leagueScheduleViewController = LeagueScheduleViewController(model: .init())
    let leagueLeadersViewController = LeagueLeadersViewController(model: .init())

    var model: Model { didSet { applyModel() } }

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
        navigationItem.rightBarButtonItem = .init(title: "<debug menu>",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(debugMenuTapped))

        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)

        leagueStandingsViewController.delegate = self
        leagueLeadersViewController.delegate = self
        leagueScheduleViewController.delegate = self
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(segmentedControl)
        addAutoLayoutChild(leagueStandingsViewController)
        addAutoLayoutChild(leagueScheduleViewController)
        addAutoLayoutChild(leagueLeadersViewController)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor),
            leagueStandingsViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            leagueStandingsViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            leagueStandingsViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            leagueStandingsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leagueScheduleViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            leagueScheduleViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            leagueScheduleViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            leagueScheduleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leagueLeadersViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            leagueLeadersViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            leagueLeadersViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            leagueLeadersViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModel()
    }


    // MARK: Actions

    @objc private func segmentedValueChanged(_ sender: UISegmentedControl) {
        updateSegment()
    }

    @objc private func simulateWeek() {
        guard let index = model.segments.firstIndex(where: { $0 == .leagueSchedule }) else { return }
        segmentedControl.selectedSegmentIndex = index
        updateSegment()
        delegate?.simulateWeek(sender: self)
    }

    @objc private func debugMenuTapped() {
        delegate?.openDebugMenu(self)
    }
}

extension LeagueViewController {
    private func updateSegment() {
        leagueStandingsViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .leagueStandings
        leagueScheduleViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .leagueSchedule
        leagueLeadersViewController.view.isHidden = model.segments[segmentedControl.selectedSegmentIndex] != .leagueLeaders
    }
}

extension LeagueViewController: LeagueStandingsViewControllerDelegate {

    func teamSelected(withId id: String, sender: LeagueStandingsViewController) {
        delegate?.teamSelected(withId: id, sender: self)
    }
}

extension LeagueViewController: LeagueScheduleViewControllerDelegate {

    func gameSelected(withId id: String, sender: LeagueScheduleViewController) {
        delegate?.gameSelected(withId: id, sender: self)
    }
}

extension LeagueViewController: LeagueLeadersViewControllerDelegate {

    func playerSelected(withId id: String, sender: LeagueLeadersViewController) {
        delegate?.playerSelected(withId: id, sender: self)
    }
}

extension LeagueViewController {
    struct Model {
        var title: String = ""
        var segments: [Segment] = []
        var leagueStandingsModel: LeagueStandingsViewController.Model = .init()
        var leagueScheduleModel: LeagueScheduleViewController.Model = .init()
        var leagueLeadersModel: LeagueLeadersViewController.Model = .init()
    }

    private func applyModel() {
        title = model.title

        for i in 0..<model.segments.count {
            segmentedControl.setTitle(model.segments[i].title, forSegmentAt: i)
        }
        leagueStandingsViewController.model = model.leagueStandingsModel
        leagueLeadersViewController.model = model.leagueLeadersModel
        leagueScheduleViewController.model = model.leagueScheduleModel

        updateSegment()
    }
}

extension LeagueViewController.Model {
    enum Segment: Equatable {

        case leagueStandings
        case leagueSchedule
        case leagueLeaders

        var title: String {
            switch self {
            case .leagueStandings: return "League Standings"
            case .leagueSchedule: return "League Schedule"
            case .leagueLeaders: return "League Leaders"
            }
        }
    }
}

// TODO: move this to an extension file
extension BaseViewController {
    func addAutoLayoutChild(_ child: UIViewController) {
        addChild(child)
        view.addAutoLayoutSubview(child.view)
        child.didMove(toParent: self)
    }
}
