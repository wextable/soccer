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
    private let viewController: PlayerLevelUpViewController
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

        let team = dataSource.data.league.team(withId: player.teamId ?? "")
        let model = PlayerLevelUpViewController.Model(player: player,
                                                      team: team,
                                                      dataStore: dataStore)
        viewController = PlayerLevelUpViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        let navController = GlassNavigationController(rootViewController: viewController)
        presenter.present(navController, animated: true)
    }
}

extension PlayerLevelUpCoordinator {
    private func reloadView(chosenSkill: Player.Rating? = nil) {
        let team = dataSource.data.league.team(withId: player.teamId ?? "")
        let model = PlayerLevelUpViewController.Model(player: player,
                                                      team: team,
                                                      dataStore: dataStore,
                                                      chosenSkill: chosenSkill)
        viewController.model = model
    }
}

extension PlayerLevelUpCoordinator: PlayerLevelUpViewControllerDelegate {
    func closeButtonTapped(_ sender: PlayerLevelUpViewController) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.finish(.finished)
        }
    }

    func ratingSelected(_ rating: Player.Rating, sender: PlayerLevelUpViewController) {

        switch rating {
        case .speed:
            guard player.ratings.speed < player.potential.speed else { return }
            player.ratings.speed = min(player.ratings.speed + GameConfig.XP.levelUpAmountSpeed,
                                       player.potential.speed)
        case .shooting:
            guard player.ratings.shooting < player.potential.shooting else { return }
            player.ratings.shooting = min(player.ratings.shooting + GameConfig.XP.levelUpAmountShooting,
                                          player.potential.shooting)
        case .passing:
            guard player.ratings.passing < player.potential.passing else { return }
            player.ratings.passing = min(player.ratings.passing + GameConfig.XP.levelUpAmountPassing,
                                         player.potential.passing)
        case .dribbling:
            guard player.ratings.dribbling < player.potential.dribbling else { return }
            player.ratings.dribbling = min(player.ratings.dribbling + GameConfig.XP.levelUpAmountDribbling,
                                           player.potential.dribbling)
        case .defending:
            guard player.ratings.defending < player.potential.defending else { return }
            player.ratings.defending = min(player.ratings.defending + GameConfig.XP.levelUpAmountDefending,
                                           player.potential.defending)
        case .goalkeeping:
            guard player.ratings.goalkeeping < player.potential.goalkeeping else { return }
            player.ratings.goalkeeping = min(player.ratings.goalkeeping + GameConfig.XP.levelUpAmountGoalkeeping,
                                             player.potential.goalkeeping)
        }

        player.xp = 0
        player.xpLevel += 1

        reloadView(chosenSkill: rating)
    }
}

