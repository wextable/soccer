//
//  PlayerCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 12/29/21.
//

import Combine
import UIKit

enum PlayerCoordinatorResult: Equatable {
    case finished
}

final class PlayerCoordinator: Coordinator<PlayerCoordinatorResult> {

    private let presentation: Presentation
    private let viewController: PlayerViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let player: Player

    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Initialization

    init(presentation: Presentation,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         player: Player) {
        self.presentation = presentation
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.player = player

        let team = dataSource.data.league.team(withId: player.teamId ?? "")
        let model = PlayerViewController.Model(shouldShowCloseButton: presentation.isPresent,
                                               player: player,
                                               team: team,
                                               dataStore: dataStore)
        viewController = PlayerViewController(model: model)
    }

    override func start() {
        viewController.delegate = self

        switch presentation {
        case .push(let navigationController):
            navigationController.pushViewController(viewController, animated: true)
        case .present(let presenter):
            let navController = GlassNavigationController(rootViewController: viewController)
            presenter.present(navController, animated: true)
        }

        if case Presentation.push(let navigationController) = presentation {
            navigationController.popPublisher(for: viewController)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.finish(.finished)
                })
                .store(in: &subscriptions)
        }
    }
}

extension PlayerCoordinator: PlayerViewControllerDelegate {

    func closeButtonTapped(_ sender: PlayerViewController) {
        switch presentation {
        case .present(let presenter):
            presenter.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.finish(.finished)
            }
        default:
            break
        }
    }

    func testing_upgradeRating(_ rating: Player.Rating) {

        let defaultRatingIncrease = 5
        switch rating {
        case .speed:
            guard player.ratings.speed < player.potential.speed else { return }
            player.ratings.speed = min(player.ratings.speed + defaultRatingIncrease,
                                       player.potential.speed)
        case .shooting:
            guard player.ratings.shooting < player.potential.shooting else { return }
            player.ratings.shooting = min(player.ratings.shooting + defaultRatingIncrease,
                                          player.potential.shooting)
        case .passing:
            guard player.ratings.passing < player.potential.passing else { return }
            player.ratings.passing = min(player.ratings.passing + defaultRatingIncrease,
                                         player.potential.passing)
        case .dribbling:
            guard player.ratings.dribbling < player.potential.dribbling else { return }
            player.ratings.dribbling = min(player.ratings.dribbling + defaultRatingIncrease,
                                           player.potential.dribbling)
        case .defending:
            guard player.ratings.defending < player.potential.defending else { return }
            player.ratings.defending = min(player.ratings.defending + defaultRatingIncrease,
                                           player.potential.defending)
        case .goalkeeping:
            guard player.ratings.goalkeeping < player.potential.goalkeeping else { return }
            player.ratings.goalkeeping = min(player.ratings.goalkeeping + defaultRatingIncrease,
                                             player.potential.goalkeeping)
        }

        player.xp = 0
        player.xpLevel += 1

        let team = dataSource.data.league.team(withId: player.teamId ?? "")
        let model = PlayerViewController.Model(shouldShowCloseButton: presentation.isPresent,
                                               player: player,
                                               team: team,
                                               dataStore: dataStore)
        viewController.model = model
    }
}
