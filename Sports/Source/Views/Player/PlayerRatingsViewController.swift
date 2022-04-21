//
//  PlayerRatingsViewController.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import UIKit

protocol PlayerRatingsViewControllerDelegate: AnyObject {
    func ratingSelected(_ rating: Player.Rating,
                        sender: PlayerRatingsViewController)
}

class PlayerRatingsViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: PlayerRatingsViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case ratings
    }
    enum Row: Hashable {
        case rating(PlayerRatingView.Model)
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

        tableView.register(PlayerRatingCell.self)
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
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -GlassSpacing.small),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .rating(let cellModel):
            guard let cellModel = model.ratingModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayerRatingCell.reuseIdentifier,
                                                     for: indexPath) as? PlayerRatingCell
            cell?.model = cellModel
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension PlayerRatingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < model.ratingModels.count else { return }

        delegate?.ratingSelected(model.ratingModels[indexPath.row].ratingType,
                                 sender: self)
    }
}

extension PlayerRatingsViewController {
    struct Model {

        struct Rating {
            var current: Player.Ratings
            var potential: Player.Ratings
        }

        var title: String = ""
        var ratingModels: [PlayerRatingView.Model] = []
    }

    private func applyModel() {
        title = model.title

        guard let tableViewDataSource = tableViewDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()

        snapshot.appendSections([.ratings])
        snapshot.appendItems(model.ratingModels.map({ .rating($0) }), toSection: .ratings)

        tableViewDataSource.apply(snapshot, animatingDifferences: true) { }
    }
}
