//
//  TeamRosterViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

protocol TeamRosterViewControllerDelegate: AnyObject {
    func playerSelected(withId id: String, sender: TeamRosterViewController)
}

class TeamRosterViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: TeamRosterViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case players
    }
    enum Row: Hashable {
        case player(PlayerListingView.Model)
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

        snapshot.appendSections([.players])
        snapshot.appendItems(model.playerModels.map({ .player($0) }), toSection: .players)

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
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        tableView.register(PlayerListingCell.self)
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

        NSLayoutConstraint.activate(
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the custom header view.
        tableView.register(PlayerListingTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .player(let cellModel):
            guard let cellModel = model.playerModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayerListingCell.reuseIdentifier,
                                                     for: indexPath) as? PlayerListingCell
            cell?.model = cellModel
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension TeamRosterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.playerModels.count else { return }
        let selectedID = model.playerModels[indexPath.row].id

        delegate?.playerSelected(withId: selectedID, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                            "sectionHeader") as! PlayerListingTableHeaderView
    }
}

class PlayerListingTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = PlayerListingView.Model(id: "",
                                            position: "Pos",
                                            name: "Name",
                                            overallText: "Ovr",
                                            offense: "Off",
                                            defense: "Def",
                                            goals: "Gol",
                                            assists: "Ast",
                                            saves: "Sav",
                                            cleanSheets: "Cln")
        let view = PlayerListingView(model: model)
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

extension TeamRosterViewController {
    struct Model {
        var title: String = ""
        var playerModels: [PlayerListingView.Model] = []
    }
}
