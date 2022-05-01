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

        
    }
}
