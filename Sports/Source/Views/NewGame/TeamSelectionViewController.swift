//
//  TeamSelectionViewController.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import UIKit

protocol TeamSelectionViewControllerDelegate: AnyObject {
    func closeTapped(_ sender: TeamSelectionViewController)
    func teamSelected(withId id: String, sender: TeamSelectionViewController)
}

class TeamSelectionViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: TeamSelectionViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case teams
    }
    enum Row: Hashable {
        case team(TeamSelectionView.Model)
    }
    typealias TableViewDataSource = UITableViewDiffableDataSource<Section, Row>
    private var tableViewDataSource: TableViewDataSource?

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(close))

        tableView.register(TeamSelectionCell.self)
        tableViewDataSource = .init(tableView: tableView) { [weak self] in
            self?.tableview(cellForRow: $2, at: $1)
        }
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
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
        tableView.register(TeamSelectionTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .team(let cellModel):
            guard let cellModel = model.teamModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSelectionCell.reuseIdentifier,
                                                     for: indexPath) as? TeamSelectionCell
            cell?.model = cellModel
            return cell
        }
    }

    @objc private func close() {
        delegate?.closeTapped(self)
    }
}

// MARK: - UITableViewDelegate

extension TeamSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.teamModels.count else { return }
        let selectedID = model.teamModels[indexPath.row].id

        delegate?.teamSelected(withId: selectedID, sender: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                            "sectionHeader") as! TeamSelectionTableHeaderView
    }
}

class TeamSelectionTableHeaderView: BaseTableViewHeaderFooterView {

    private let headerView: UIView = {
        let model = TeamSelectionView.Model(id: "",
                                            image: nil,
                                            name: "Team",
                                            prestige: "Prestige")
        let view = TeamSelectionView(model: model)
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

extension TeamSelectionViewController {
    struct Model {
        var title: String = ""
        var teamModels: [TeamSelectionView.Model] = []
    }

    private func applyModel() {
        title = model.title

        guard let tableViewDataSource = tableViewDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()

        snapshot.appendSections([.teams])
        snapshot.appendItems(model.teamModels.map({ .team($0) }), toSection: .teams)

        tableViewDataSource.apply(snapshot, animatingDifferences: true) { }
    }
}
