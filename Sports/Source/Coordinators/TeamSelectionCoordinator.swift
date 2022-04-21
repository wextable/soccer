//
//  TeamSelectionCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import UIKit

enum TeamSelectionCoordinatorResult: Equatable {
    case finished(team: Team)
}

final class TeamSelectionCoordinator: Coordinator<TeamSelectionCoordinatorResult> {

    private let presenter: UIViewController
    private let viewController: TeamSelectionViewController
    private let dataSource: LeagueDataSource

    // MARK: Initialization

    init(presenter: UIViewController,
         dataSource: LeagueDataSource) {
        self.presenter = presenter
        self.dataSource = dataSource

        let model = TeamSelectionViewController.Model(teams: dataSource.data.league.teams)
        viewController = TeamSelectionViewController(model: model)
    }

    override func start() {
        viewController.delegate = self

        let navController = GlassNavigationController(rootViewController: viewController)
        presenter.present(navController, animated: true)
    }
}

extension TeamSelectionCoordinator: TeamSelectionViewControllerDelegate {
    func closeTapped(_ sender: TeamSelectionViewController) {
        viewController.dismiss(animated: true)
    }

    func teamSelected(withId id: String, sender: TeamSelectionViewController) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.finish(.finished(team: self.dataSource.data.league.team(withId: id)))
        }
    }
}
