//
//  GameSummaryCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 2/26/22.
//

import Combine
import UIKit

enum GameSummaryCoordinatorResult: Equatable {
    case dismissed
    case popped(didAdvanceWeek: Bool)
}

final class GameSummaryCoordinator: Coordinator<GameSummaryCoordinatorResult> {
    private let presentation: Presentation
    private let viewController: GameSummaryViewController
    private let dataSource: LeagueDataSource
    private let dataStore: DataStore
    private let game: Game
    private var weekDidAdvance = false

    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Initialization

    init(presentation: Presentation,
         dataSource: LeagueDataSource,
         dataStore: DataStore,
         game: Game,
         canPlay: Bool = false,
         recordAdjustment: RecordAdjustment = .init()) {
        self.presentation = presentation
        self.dataSource = dataSource
        self.dataStore = dataStore
        self.game = game

        let model = GameSummaryViewController.Model(game: game,
                                                    in: dataSource.data.league,
                                                    dataStore: dataStore,
                                                    canPlay: canPlay,
                                                    recordAdjustment: recordAdjustment)
        viewController = GameSummaryViewController(model: model)
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
                    self.finish(.popped(didAdvanceWeek: self.weekDidAdvance))
                })
                .store(in: &subscriptions)
        }
    }
}

extension GameSummaryCoordinator: GameSummaryViewControllerDelegate {

    func playerSelected(withID id: String, sender: GameSummaryViewController) {
        guard let player = dataSource.data.league.player(withId: id) else { return }
        
        let coordinator = PlayerCoordinator(presentation: .present(viewController),
                                            dataSource: dataSource,
                                            dataStore: dataStore,
                                            player: player)
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func playGameButtonTapped(_ sender: GameSummaryViewController) {
        dataSource.simulateWeek()

        let coordinator = GameHighlightsCoordinator(presenter: viewController,
                                                    dataSource: dataSource,
                                                    dataStore: dataStore,
                                                    game: game)
        addChild(coordinator: coordinator)

        coordinator.onFinish = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .finished:
                self.weekDidAdvance = true
                let model = GameSummaryViewController.Model(game: self.game,
                                                            in: self.dataSource.data.league,
                                                            dataStore: self.dataStore)
                self.viewController.model = model
            }
        }


        coordinator.start()
    }

    func hightlightsButtonTapped(_ sender: GameSummaryViewController) {
        let coordinator = GameHighlightsCoordinator(presenter: viewController,
                                                    dataSource: dataSource,
                                                    dataStore: dataStore,
                                                    game: game)
        addChild(coordinator: coordinator)
        coordinator.start()
    }

    func dismiss(_ sender: GameSummaryViewController) {
        finish(.dismissed)
        viewController.dismiss(animated: true)
    }
}
