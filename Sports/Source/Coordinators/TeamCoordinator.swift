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

    func player(withId id: String,
                startingToggled isStarting: Bool,
                sender: TeamViewController) {
        let player = team.players.first(where: { $0.id == id })!
        player.isStarting = isStarting
        reloadView()
    }

    func myLeagueSelected(_ sender: TeamViewController) {
        let leagueCoordinator = LeagueCoordinator(navigationController: navigationController,
                                                  dataSource: dataSource,
                                                  dataStore: dataStore,
                                                  league: dataSource.data.league)

        addChild(coordinator: leagueCoordinator)
        leagueCoordinator.start()
    }

    func playGameSelected(_ sender: TeamViewController) {
        let currentWeek = dataSource.data.league.currentWeek
        guard currentWeek < team.schedule.count,
              let currentGame = team.schedule[currentWeek] else {
                  return
              }

        guard let game = dataSource.data.league.game(withId: currentGame.id) else { return }

        guard team.isStartingLineupSet else {
            showAlert(title: "Starting Lineup",
                      message: "Complete your starting lineup before playing.")
            return
        }

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

    private func reloadView() {
        let model = TeamViewController.Model(team: team,
                                             in: dataSource.data.league)
        viewController.model = model
    }
    
    private func handleGameFinished(result: GameSummaryCoordinatorResult) {
        switch result {
        case .popped(let didAdvanceWeek):
            if didAdvanceWeek {
                levelUpPlayers() { [weak self] in
                    guard let self = self else { return }
                    self.handleInjuries() { [weak self] in
                        guard let self = self else { return }
                        self.reloadView()
                    }
                }
            }
        default:
            break
        }
    }

    private func handleInjuries(completion: @escaping () -> Void) {
        if let newlyInjured = team.players.first(where: { $0.injury?.isNew == true }) {
            let playerName = "\(newlyInjured.fullName) (\(newlyInjured.position.shortName))"
            showAlert(title: "Uh oh!",
                      message: newlyInjured.injury!.notification(playerName: playerName)) { [weak self] _ in
                self?.progressInjuries(completion: completion)
            }
        } else {
            progressInjuries(completion: completion)
        }
    }

    private func progressInjuries(completion: @escaping () -> Void) {
        let newlyRecoveredPlayers = team.players.filter { $0.injury?.isRecovered == true }
        guard !newlyRecoveredPlayers.isEmpty else {
            completion()
            return
        }

        var recoveryMessage: String = "The following players have recovered from their injuries:"
        for player in newlyRecoveredPlayers {
            let playerName = "\(player.fullName) (\(player.position.shortName))"
            recoveryMessage += "\n\(playerName) (\(player.injury!.type.rawValue))"
        }

        showAlert(title: "Recovery!", message: recoveryMessage) { _ in
            completion()
        }
    }

    private func levelUpPlayers(completion: @escaping () -> Void) {
        let playersToLevelUp = team.players.filter {
            // TODO: once we have an economy, remove the hasReachedPotential part
            $0.xp >= $0.potentialXP && !$0.hasReachedPotential
        }
        levelUpPlayer(playersToLevelUp.first,
                      from: playersToLevelUp,
                      completion: completion)
    }

    private func levelUpPlayer(_ player: Player?,
                               from pool: [Player],
                               completion: @escaping () -> Void) {
        guard let player = player else {
            completion()
            return
        }

        let coordinator = PlayerLevelUpCoordinator(presenter: viewController,
                                                   dataSource: dataSource,
                                                   dataStore: dataStore,
                                                   player: player)
        addChild(coordinator: coordinator)
        coordinator.onFinish = { [weak self] result in
            guard let self = self else { return }

            var remainingPool = pool
            remainingPool.remove(at: 0)
            self.levelUpPlayer(remainingPool.first,
                               from: remainingPool,
                               completion: completion)
        }
        coordinator.start()
    }
}

private extension TeamCoordinator {
    func showAlert(title: String,
                   message: String,
                   confirmCompletion: ((UIAlertAction) -> Void)? = nil) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK",
                                        style: .default,
                                        handler: confirmCompletion)
        controller.addAction(action)
        navigationController.present(controller, animated: true, completion: nil)
    }
}
