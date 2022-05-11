//
//  LeagueCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

enum LeagueCoordinatorResult: Equatable {
    case finished
}

final class LeagueCoordinator: Coordinator<LeagueCoordinatorResult> {

    private let navigationController: GlassNavigationController
    private let viewController: LeagueViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let league: League

    // MARK: Initialization

    init(navigationController: GlassNavigationController,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         league: League) {
        self.navigationController = navigationController
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.league = league

        let model = LeagueViewController.Model(league: league,
                                               week: dataSource.data.league.currentWeek)
        viewController = LeagueViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: true)

    }
}

extension LeagueCoordinator: LeagueViewControllerDelegate {
    func teamSelected(withId id: String, sender: LeagueViewController) {
        guard id != dataSource.data.league.userTeamId else {
            navigationController.popViewController(animated: true)
            return
        }

        let coordinator = TeamCoordinator(navigationController: navigationController,
                                          dataSource: dataSource,
                                          dataStore: dataStore,
                                          team: league.team(withId: id))
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func playerSelected(withId id: String, sender: LeagueViewController) {
        guard let player = league.player(withId: id) else { return }
        let coordinator = PlayerCoordinator(presentation: .push(navigationController),
                                            dataSource: dataSource,
                                            dataStore: dataStore,
                                            player: player)
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func gameSelected(withId id: String, sender: LeagueViewController) {
        guard let game = league.game(withId: id) else { return }
        let coordinator = GameSummaryCoordinator(presentation: .push(navigationController),
                                                 dataSource: dataSource,
                                                 dataStore: dataStore,
                                                 game: game)
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func simulateWeek(sender: LeagueViewController) {
        dataSource.simulateWeek()

        let model = LeagueViewController.Model(league: dataSource.data.league,
                                               week: dataSource.data.league.currentWeek - 1)
        viewController.model = model
    }

    func openDebugMenu(_ sender: LeagueViewController) {
        let coordinator = DebugMenuCoordinator(presenter: navigationController)
        addChild(coordinator: coordinator)
        coordinator.start()
    }
}
