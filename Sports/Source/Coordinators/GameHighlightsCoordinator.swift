//
//  GameHighlightsCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 2/28/22.
//

import UIKit

enum GameHighlightsCoordinatorResult: Equatable {
    case finished
}

final class GameHighlightsCoordinator: Coordinator<GameHighlightsCoordinatorResult> {
    private let presenter: UIViewController
    private let viewController: GameHighlightsViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let game: Game

    // MARK: Initialization

    init(presenter: UIViewController,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         game: Game) {
        self.presenter = presenter
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.game = game

        let model = GameHighlightsViewController.Model(game: game,
                                                       league: dataSource.data.league,
                                                       dataStore: dataStore)
        viewController = GameHighlightsViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        presenter.present(viewController, animated: true)
    }
}

extension GameHighlightsCoordinator: GameHighlightsViewControllerDelegate {

    func closeButtonTapped(_ sender: GameHighlightsViewController) {
        viewController.dismiss(animated: true) {
            self.finish(.finished)
        }
    }

    func halftimeReached(_ sender: GameHighlightsViewController) {

        let adjustment: RecordAdjustment
        if game.homeScore > game.awayScore {
            adjustment = RecordAdjustment(homeWinAdjustment: -1, awayLossAdjustment: -1)
        } else if game.awayScore > game.homeScore {
            adjustment = RecordAdjustment(awayWinAdjustment: -1, homeLossAdjustment: -1)
        } else {
            adjustment = RecordAdjustment(homeTieAdjustment: -1, awayTieAdjustment: -1)
        }

        let halfGame = Game(id: "temp",
                            homeTeamId: game.homeTeamId,
                            awayTeamId: game.awayTeamId,
                            week: game.week)

        for shot in game.shots {
            if shot.minute <= 45 {
                halfGame.shots.append(shot)
                if shot.result == .goal {
                    if shot.isForHomeTeam {
                        halfGame.homeScore += 1
                    } else {
                        halfGame.awayScore += 1
                    }
                }
            }
        }
        halfGame.state = .halftime

        let coordinator = GameSummaryCoordinator(presentation: .present(viewController),
                                                 dataSource: dataSource,
                                                 dataStore: dataStore,
                                                 game: halfGame,
                                                 recordAdjustment: adjustment)

        coordinator.onFinish = { [weak self] result in
            switch result {
            case .dismissed:
                self?.viewController.startSecondHalf()
            default:
                break
            }
        }

        addChild(coordinator: coordinator)
        coordinator.start()
    }
}

// TODO: fix this, it's awful
struct RecordAdjustment {
    var homeWinAdjustment = 0
    var awayWinAdjustment = 0
    var homeLossAdjustment = 0
    var awayLossAdjustment = 0
    var homeTieAdjustment = 0
    var awayTieAdjustment = 0
}
