//
//  LeagueLeadersViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/30/21.
//

import UIKit

protocol LeagueLeadersViewControllerDelegate: AnyObject {
    func playerSelected(withId id: String, sender: LeagueLeadersViewController)
}

class LeagueLeadersViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: LeagueLeadersViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case players
    }
    enum Row: Hashable {
        case player(LeagueLeaderView.Model)
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
        tableView.register(LeagueLeaderCell.self)
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
        tableView.register(LeagueLeadersTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .player(let cellModel):
            guard let cellModel = model.playerModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: LeagueLeaderCell.reuseIdentifier,
                                                     for: indexPath) as? LeagueLeaderCell
            cell?.model = cellModel
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension LeagueLeadersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.playerModels.count else { return }
        let playerModel = model.playerModels[indexPath.row]

        delegate?.playerSelected(withId: playerModel.id, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                            "sectionHeader") as! LeagueLeadersTableHeaderView
    }
}

class LeagueLeadersTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = LeagueLeaderView.Model(id: "",
                                           ranking: "Rnk",
                                           position: "Pos",
                                           positionColor: GlassLabelStyle.body2.textColor.uiColor,
                                           name: "Name",
                                           teamModel: .init(icon: nil, text: "Team"),
                                           goals: "Gol",
                                           assists: "Ast",
                                           saves: "Sav",
                                           cleanSheets: "Cln",
                                           overallText: "Ovr")
        let view = LeagueLeaderView(model: model)
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

    private func configureAccessibility() {
        //        headerLabel.accessibilityTraits = .header
        //        headerLabel.accessibilityIdentifier = model?.accessibilityIdentifier
    }

    func setHeaderLabelVisibility(alpha: CGFloat) {
        //        headerLabel.alpha = alpha
    }
}

extension LeagueLeadersViewController {
    struct Model {
        var title: String = ""
        var playerModels: [LeagueLeaderView.Model] = []
    }
}

