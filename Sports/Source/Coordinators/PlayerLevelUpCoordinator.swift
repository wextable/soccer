//
//  PlayerLevelUpCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import UIKit

enum PlayerLevelUpCoordinatorResult: Equatable {
    case finished
}

final class PlayerLevelUpCoordinator: Coordinator<PlayerLevelUpCoordinatorResult> {

    private let presenter: UIViewController
    private let viewController: PlayerRatingsViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let player: Player

    // MARK: Initialization

    init(presenter: UIViewController,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         player: Player) {
        self.presenter = presenter
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.player = player

        let model = PlayerRatingsViewController.Model(player: player)
        viewController = PlayerRatingsViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        let navController = GlassNavigationController(rootViewController: viewController)
        presenter.present(navController, animated: true)
    }
}

extension PlayerLevelUpCoordinator: PlayerRatingsViewControllerDelegate {
    func ratingSelected(_ rating: Player.Rating, sender: PlayerRatingsViewController) {
        switch rating {
        case .speed: player.ratings.speed += 5
        case .shooting: player.ratings.shooting += 5
        case .passing: player.ratings.passing += 5
        case .dribbling: player.ratings.dribbling += 5
        case .defending: player.ratings.defending += 5
        case .goalkeeping: player.ratings.goalkeeping += 3
        }

        viewController.dismiss(animated: true) { [weak self] in
            self?.finish(.finished)
        }
    }
}

