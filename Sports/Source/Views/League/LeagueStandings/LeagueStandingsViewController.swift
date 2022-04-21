//
//  LeagueStandingsViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

protocol LeagueStandingsViewControllerDelegate: AnyObject {
    func teamSelected(withId id: String, sender: LeagueStandingsViewController)
}

class LeagueStandingsViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: LeagueStandingsViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case teams
    }
    enum Row: Hashable {
        case team(TeamStandingsView.Model)
    }
    typealias TableViewDataSource = UITableViewDiffableDataSource<Section, Row>
    private var tableViewDataSource: TableViewDataSource?

    var model: Model {
        didSet { applyModel() }
    }

    private func applyModel() {
        title = model.title

        guard let tableViewDataSource = tableViewDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()

        snapshot.appendSections([.teams])
        snapshot.appendItems(model.teamStandingModels.map({ .team($0) }), toSection: .teams)

        tableViewDataSource.apply(snapshot, animatingDifferences: true) { }
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
        
        tableView.register(TeamStandingsCell.self)
        tableViewDataSource = .init(tableView: tableView) { [weak self] in
            self?.tableview(cellForRow: $2, at: $1)
        }
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .none
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(tableView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        tableView.constraints(pinningTo: view).activate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the custom header view.
        tableView.register(LeageStandingsTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .team(let cellModel):
            guard let cellModel = model.teamStandingModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamStandingsCell.reuseIdentifier,
                                                     for: indexPath) as? TeamStandingsCell
            cell?.model = cellModel
            return cell
        }
    }

    // MARK: Actions

    @objc private func leagueLeadersTapped() {
        //delegate?.leagueLeadersTapped(self)
    }

}

extension LeagueStandingsViewController {
    struct Model {
        var title: String = ""
        var teamStandingModels: [TeamStandingsView.Model] = []
    }
}

// MARK: - UITableViewDelegate

extension LeagueStandingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.teamStandingModels.count else { return }
        let selectedID = model.teamStandingModels[indexPath.row].id

        delegate?.teamSelected(withId: selectedID, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! LeageStandingsTableHeaderView
//        header.delegate = self
        return header
    }
}

extension LeagueStandingsViewController: SortableTableHeaderViewDelegate {
    func columnTapped(_ column: SortableTableHeaderView.Model.Column) {
//        switch column.id {
//        case "ranking": print("TAPPED Ranking, will now sort")
//        case "displayName": delegate?.columnTapped()
//        default: break
//        }
    }
}

class LeageStandingsTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = TeamStandingsView.Model(id: "",
                                            ranking: "#",
                                            teamModel: .init(icon: nil, text: "Team"),
                                            wins: "W",
                                            draws: "D",
                                            losses: "L",
                                            points: "Pts",
                                            goalsFor: "GF",
                                            goalsAgainst: "GA",
                                            goalDifferential: "GD",
                                            offense: "Off",
                                            defense: "Def",
                                            overall: "Ovr"
        )
        let view = TeamStandingsView(model: model)
        view.backgroundColor = GlassColor.gray20.uiColor
        return view
    }()

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(headerView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate([
            headerView.constraints(pinningTo: safeAreaLayoutGuide, edges: .all),
        ])
    }

}
