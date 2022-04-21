//
//  LeagueScheduleViewController.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

import UIKit

protocol LeagueScheduleViewControllerDelegate: AnyObject {
    func gameSelected(withId id: String, sender: LeagueScheduleViewController)
}

class LeagueScheduleViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: LeagueScheduleViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case games
    }
    enum Row: Hashable {
        case game(GameScheduleView.Model)
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

        snapshot.appendSections([.games])
        snapshot.appendItems(model.gameScheduleModels.map({ .game($0) }), toSection: .games)

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

        tableView.register(GameScheduleCell.self)
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
        tableView.register(LeagueScheduleTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .game(let cellModel):
            guard let cellModel = model.gameScheduleModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: GameScheduleCell.reuseIdentifier,
                                                     for: indexPath) as? GameScheduleCell
            cell?.model = cellModel
            return cell
        }
    }

    // MARK: Actions

    @objc private func leagueLeadersTapped() {
        //delegate?.leagueLeadersTapped(self)
    }

}

extension LeagueScheduleViewController {
    struct Model {
        var title: String = ""
        var gameScheduleModels: [GameScheduleView.Model] = []
    }
}

// MARK: - UITableViewDelegate

extension LeagueScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.gameScheduleModels.count else { return }
        let gameId = model.gameScheduleModels[indexPath.row].id
        delegate?.gameSelected(withId: gameId, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! LeagueScheduleTableHeaderView
        //        header.delegate = self
        return header
    }
}

class LeagueScheduleTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = GameScheduleView.Model(awayRanking: " ",
                                           awayTeamModel: .init(icon: nil, text: "Away"),
                                           score: "vs.",
                                           homeRanking: " ",
                                           homeTeamModel: .init(icon: nil, text: "Home"))
        let view = GameScheduleView(model: model)
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

