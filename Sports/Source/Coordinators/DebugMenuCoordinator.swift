//
//  DebugMenuCoordinator.swift
//  Sports
//
//  Created by Wesley St. John on 5/2/22.
//

import UIKit

enum DebugMenuCoordinatorResult: Equatable {
    case finished
}

final class DebugMenuCoordinator: Coordinator<DebugMenuCoordinatorResult> {

    private let presenter: UIViewController
    private let viewController: DebugMenuViewController
    private var configuration: Configuration

    // MARK: Initialization

    init(presenter: UIViewController) {
        self.presenter = presenter
        configuration = GameConfig.config

        let model = DebugMenuViewController.Model(configuration: configuration)
        viewController = DebugMenuViewController(model: model)
    }

    override func start() {
        viewController.delegate = self
        let navController = GlassNavigationController(rootViewController: viewController)
        presenter.present(navController, animated: true)
    }
}

extension DebugMenuCoordinator {
    private func reloadView() {
        let model = DebugMenuViewController.Model(configuration: configuration)
        viewController.model = model
    }
}

extension DebugMenuCoordinator: DebugMenuViewControllerDelegate {
    func settingUpdated(_ setting: DebugMenuViewController.Model.Setting, newValue: String) {

        var intValue: Int?
        var doubleValue: Double?
        switch setting.type {
        case .wholeNumber:
            guard let castInt = Int(newValue) else { return }
            intValue = castInt
        case .decimalNumber:
            guard let castDouble = Double(newValue) else { return }
            doubleValue = castDouble
        }

        switch setting.name {
        case "ratingDiffPerGoal": configuration.gameAI.ratingDiffPerGoal = doubleValue!
        case "homeFieldAdvantage": configuration.gameAI.homeFieldAdvantage = doubleValue!
        case "halfWidthGoalBellCurve": configuration.gameAI.halfWidthGoalBellCurve = doubleValue!
        case "requiredBaseXP": configuration.xp.requiredBaseXP = intValue!
        case "requiredXpPerLevel": configuration.xp.requiredXpPerLevel = intValue!
        case "standardXpBump": configuration.xp.standardXpBump = intValue!
        case "goalXpBump": configuration.xp.goalXpBump = intValue!
        case "assistXpBump": configuration.xp.assistXpBump = intValue!
        case "saveXpBump": configuration.xp.saveXpBump = intValue!
        case "keeperCleanSheetXpBump": configuration.xp.keeperCleanSheetXpBump = intValue!
        case "defenderCleanSheetXpBump": configuration.xp.defenderCleanSheetXpBump = intValue!
        case "levelUpAmountSpeed": configuration.xp.levelUpAmountSpeed = intValue!
        case "levelUpAmountShooting": configuration.xp.levelUpAmountShooting = intValue!
        case "levelUpAmountPassing": configuration.xp.levelUpAmountPassing = intValue!
        case "levelUpAmountDribbling": configuration.xp.levelUpAmountDribbling = intValue!
        case "levelUpAmountDefending": configuration.xp.levelUpAmountDefending = intValue!
        case "levelUpAmountGoalkeeping": configuration.xp.levelUpAmountGoalkeeping = intValue!
        case "standardGameFatigue": configuration.condition.standardGameFatigue = intValue!
        case "standardWeeklyRegeneration": configuration.condition.standardWeeklyRegeneration = intValue!
        case "effectivenesFactor": configuration.condition.effectivenesFactor = doubleValue!
        case "minConditionForSub": configuration.teamAI.minConditionForSub = intValue!
        case "maxConditionForSub": configuration.teamAI.maxConditionForSub = intValue!
        case "injuryChanceCondition1": configuration.injury.injuryChanceCondition1 = intValue!
        case "injuryChanceCondition20": configuration.injury.injuryChanceCondition20 = intValue!
        case "injuryChanceCondition40": configuration.injury.injuryChanceCondition40 = intValue!
        case "injuryChanceCondition60": configuration.injury.injuryChanceCondition60 = intValue!
        case "injuryChanceCondition80": configuration.injury.injuryChanceCondition80 = intValue!
        case "conditionUponRecovery": configuration.injury.conditionUponRecovery = intValue!
        default: return
        }

        reloadView()
    }

    func cancelTapped(_ sender: DebugMenuViewController) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.finish(.finished)
        }
    }

    func resetTapped(_ sender: DebugMenuViewController) {
        GameConfig.resetToDefaultConfiguration()
        configuration = GameConfig.config
        reloadView()
    }

    func saveTapped(_ sender: DebugMenuViewController) {

        GameConfig.setCustomConfiguration(configuration)

        viewController.dismiss(animated: true) { [weak self] in
            self?.finish(.finished)
        }
    }
}
