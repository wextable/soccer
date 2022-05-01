//
//  HomeCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 12/27/21.
//

import UIKit

enum HomeCoordinatorResult: Equatable {
    case finished
}

final class HomeCoordinator: Coordinator<HomeCoordinatorResult> {

    private let window: UIWindow
    private let navigationController: GlassNavigationController
    private let viewController: HomeViewController

    private let dataSource: LeagueDataSource
    private let dataStore = DataStore()

    private var lastLeagueID: String?

    // MARK: Initialization

    init(window: UIWindow = UIWindow(frame: UIScreen.main.bounds)) {
        self.window = window
        viewController = HomeViewController()
        navigationController = GlassNavigationController(rootViewController: viewController)
        dataSource = LeagueDataSource(dataStore: dataStore)
    }

    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        var loadLeagueButtonTitle: String?
        if let savedLeague = dataStore.loadLastLeagueSave() {
            lastLeagueID = savedLeague.id
            loadLeagueButtonTitle = "Continue season"
        }

        let mainDescription = """
        Generate a league of teams.
Each team will play every other team.
See the results!
"""
        let foo = HomeViewController.Model(title: "Soccer Simulator",
                                           mainDescription: mainDescription,
                                           newLeagueButtonTitle: "Start new season",
                                           loadLeagueButtonTitle: loadLeagueButtonTitle)
        viewController.model = foo
        viewController.delegate = self
    }
}

extension HomeCoordinator {

    private func startNewSeason(numTeams: Int) {
        let league = LeagueFactory.makeLeague(numTeams: numTeams)
        dataSource.setLeague(league)
    }

    private func simulateSeason() {
        dataSource.simulateSeason()
//        for week in dataSource.data.league.schedule {
//            for game in week {
//                let home = dataSource.data.league.team(withId: game.homeTeamId)
//                let away = dataSource.data.league.team(withId: game.awayTeamId)
//                GameSimulator.simulateGame(game, homeTeam: home, awayTeam: away)
//                dataSource.recordGameStats(game)
//            }
//        }
//        dataStore.saveLeague(dataSource.data.league)
        
    }

    private func goToTeamSelection() {
        let teamSelectionCoordinator = TeamSelectionCoordinator(presenter: navigationController,
                                                                dataSource: dataSource)

        addChild(coordinator: teamSelectionCoordinator)
        teamSelectionCoordinator.onFinish = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .finished(let team):
                self.goToMyTeamCoordinator(teamId: team.id)
            }
        }
        teamSelectionCoordinator.start()
    }

    private func goToMyTeamCoordinator(teamId: String? = nil) {
        if let teamId = teamId {
            dataSource.data.league.userTeamId = teamId
        }
        let team = dataSource.data.league.team(withId: dataSource.data.league.userTeamId)
        let teamCoordinator = TeamCoordinator(navigationController: navigationController,
                                              dataSource: dataSource,
                                              dataStore: dataStore,
                                              team: team)

        addChild(coordinator: teamCoordinator)
        teamCoordinator.start()
    }
}

extension HomeCoordinator: HomeViewControllerDelegate {
    func loadGame() {
        guard let lastLeagueID = lastLeagueID,
              let league = dataStore.loadLeague(withID: lastLeagueID) else {
                  return
              }

        dataSource.setLeague(league)
        goToMyTeamCoordinator()
    }

    func startGame() {
        startNewSeason(numTeams: 20)
        goToTeamSelection()
    }
}
