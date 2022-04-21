//
//  TeamCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

enum TeamCoordinatorResult: Equatable {
    case finished
}

final class TeamCoordinator: Coordinator<TeamCoordinatorResult> {

    private let navigationController: GlassNavigationController
    private let viewController: TeamViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let team: Team

    // MARK: Initialization

    init(navigationController: GlassNavigationController,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         team: Team) {
        self.navigationController = navigationController
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.team = team

        let model = TeamViewController.Model(team: team,
                                             in: dataSource.data.league)
        viewController = TeamViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension TeamCoordinator: TeamViewControllerDelegate {
    
    func playerSelected(withId id: String, sender: TeamViewController) {
        let player = team.players.first(where: { $0.id == id })!
        let coordinator = PlayerCoordinator(presentation: .push(navigationController),
                                            dataSource: dataSource,
                                            dataStore: dataStore,
                                            player: player)
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func myLeagueSelected(_ sender: TeamViewController) {
        let leagueCoordinator = LeagueCoordinator(navigationController: navigationController,
                                                  dataSource: dataSource,
                                                  dataStore: dataStore,
                                                  league: dataSource.data.league)

        addChild(coordinator: leagueCoordinator)
        leagueCoordinator.start()
    }


    private func levelUpPlayer(_ player: Player?, from pool: [Player]) {
        guard let player = player else { return }

        let coordinator = PlayerLevelUpCoordinator(presenter: viewController,
                                                   dataSource: dataSource,
                                                   dataStore: dataStore,
                                                   player: player)
        addChild(coordinator: coordinator)
        coordinator.onFinish = { [weak self] result in
            guard let self = self else { return }
            let model = TeamViewController.Model(team: self.team,
                                                 in: self.dataSource.data.league)
            self.viewController.model = model

            var remainingPool = pool
            remainingPool.remove(at: 0)
            self.levelUpPlayer(remainingPool.first, from: remainingPool)
        }
        coordinator.start()
    }

    func playGameSelected(_ sender: TeamViewController) {
        let currentWeek = dataSource.data.league.currentWeek
        guard currentWeek < team.schedule.count,
              let currentGame = team.schedule[currentWeek] else {
                  return
              }

        guard let game = dataSource.data.league.game(withId: currentGame.id) else { return }
        let coordinator = GameSummaryCoordinator(presentation: .push(navigationController),
                                                 dataSource: dataSource,
                                                 dataStore: dataStore,
                                                 game: game,
                                                 canPlay: true)
        addChild(coordinator: coordinator)
        coordinator.onFinish = { [weak self] result in
            guard let self = self else { return }
            self.handleGameFinished(result: result)
        }
        coordinator.start()
    }

    func gameSelected(withId id: String, sender: TeamViewController) {
        let league = dataSource.data.league
        guard let game = league.game(withId: id) else { return }

        let canPlay = team.id == league.userTeamId && game.week == league.currentWeek
        let coordinator = GameSummaryCoordinator(presentation: .push(navigationController),
                                                 dataSource: dataSource,
                                                 dataStore: dataStore,
                                                 game: game,
                                                 canPlay: canPlay)
        addChild(coordinator: coordinator)
        coordinator.onFinish = { [weak self] result in
            guard let self = self else { return }
            self.handleGameFinished(result: result)
        }
        coordinator.start()
    }
}

extension TeamCoordinator {
    
    private func handleGameFinished(result: GameSummaryCoordinatorResult) {
        switch result {
        case .popped(let didAdvanceWeek):
            if didAdvanceWeek {
                let model = TeamViewController.Model(team: team,
                                                     in: dataSource.data.league)
                viewController.model = model
            }
        default:
            break
        }
    }
}
