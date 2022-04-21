//
//  TeamScheduleViewController.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

protocol TeamScheduleViewControllerDelegate: AnyObject {
    func gameSelected(withId id: String, sender: TeamScheduleViewController)
}

class TeamScheduleViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: TeamScheduleViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case games
    }
    enum Row: Hashable {
        case game(TeamGameScheduleView.Model)
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
        snapshot.appendItems(model.teamGameScheduleModels.map({ .game($0) }), toSection: .games)

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

        tableView.register(TeamGameScheduleCell.self)
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
        tableView.register(TeamScheduleTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .game(let cellModel):
            guard let cellModel = model.teamGameScheduleModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamGameScheduleCell.reuseIdentifier,
                                                     for: indexPath) as? TeamGameScheduleCell
            cell?.model = cellModel
            return cell
        }
    }

}

extension TeamScheduleViewController {
    struct Model {
        var title: String = ""
        var teamGameScheduleModels: [TeamGameScheduleView.Model] = []
    }
}

// MARK: - UITableViewDelegate

extension TeamScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.teamGameScheduleModels.count else { return }
        let gameId = model.teamGameScheduleModels[indexPath.row].id
        delegate?.gameSelected(withId: gameId, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! TeamScheduleTableHeaderView
        //        header.delegate = self
        return header
    }
}

class TeamScheduleTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = TeamGameScheduleView.Model(awayRanking: " ",
                                               awayTeamModel: .init(icon: nil, text: "Away"),
                                               score: "vs.",
                                               homeRanking: " ",
                                               homeTeamModel: .init(icon: nil, text: "Home"))
        let view = TeamGameScheduleView(model: model)
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

