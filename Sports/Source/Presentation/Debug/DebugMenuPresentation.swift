//
//  DebugMenuPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 5/2/22.
//

import UIKit

extension DebugMenuViewController.Model {

    init(configuration: Configuration) {
        self.init(title: "Game Config",
                  gameAISettings: Sports.gameAiSettings(configuration),
                  xpSettings: Sports.xpSettings(configuration),
                  conditionSettings: Sports.conditionSettings(configuration),
                  teamAISettings: Sports.teamAiSettings(configuration),
                  injurySettings: Sports.injurySettings(configuration))
    }
}

private func gameAiSettings(_ config: Configuration) -> [DebugMenuViewController.Model.Setting] {
    return [
        .init(name: "ratingDiffPerGoal", displayValue: "\(config.gameAI.ratingDiffPerGoal)", type: .decimalNumber,
              description: "Amount of diff in rating to equal a std goal scored (higher = more even scores)"),
        .init(name: "homeFieldAdvantage", displayValue: "\(config.gameAI.homeFieldAdvantage)", type: .decimalNumber,
              description: "Number of extra std goals scored by the home team"),
        .init(name: "halfWidthGoalBellCurve", displayValue: "\(config.gameAI.halfWidthGoalBellCurve)", type: .decimalNumber,
              description: "Half width of the 'rolled' goal bell curve (+/- diff from std goal score)")

    ]
}

private func xpSettings(_ config: Configuration) -> [DebugMenuViewController.Model.Setting] {
    return [
        .init(name: "requiredBaseXP", displayValue: "\(config.xp.requiredBaseXP)", type: .wholeNumber,
             description: "Minumum XP required for anyone to level up"),
        .init(name: "requiredXpPerLevel", displayValue: "\(config.xp.requiredXpPerLevel)", type: .wholeNumber,
              description: "Additional XP required per level to level up"),
        .init(name: "standardXpBump", displayValue: "\(config.xp.standardXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded per game played"),
        .init(name: "goalXpBump", displayValue: "\(config.xp.goalXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded per goal scored"),
        .init(name: "assistXpBump", displayValue: "\(config.xp.assistXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded per assist"),
        .init(name: "saveXpBump", displayValue: "\(config.xp.saveXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded per save"),
        .init(name: "keeperCleanSheetXpBump", displayValue: "\(config.xp.keeperCleanSheetXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded to keeper for a clean sheet"),
        .init(name: "defenderCleanSheetXpBump", displayValue: "\(config.xp.defenderCleanSheetXpBump)", type: .wholeNumber,
              description: "Amount of XP awarded to each defender for a clean sheet"),
        .init(name: "levelUpAmountSpeed", displayValue: "\(config.xp.levelUpAmountSpeed)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),
        .init(name: "levelUpAmountShooting", displayValue: "\(config.xp.levelUpAmountShooting)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),
        .init(name: "levelUpAmountPassing", displayValue: "\(config.xp.levelUpAmountPassing)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),
        .init(name: "levelUpAmountDribbling", displayValue: "\(config.xp.levelUpAmountDribbling)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),
        .init(name: "levelUpAmountDefending", displayValue: "\(config.xp.levelUpAmountDefending)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),
        .init(name: "levelUpAmountGoalkeeping", displayValue: "\(config.xp.levelUpAmountGoalkeeping)", type: .wholeNumber,
              description: "Amount this skill will increase when chosen to level up"),

    ]
}

private func conditionSettings(_ config: Configuration) -> [DebugMenuViewController.Model.Setting] {
    return [
        .init(name: "standardGameFatigue", displayValue: "\(config.condition.standardGameFatigue)", type: .wholeNumber,
              description: "Amount condition decreases after playing in a game"),
        .init(name: "standardWeeklyRegeneration", displayValue: "\(config.condition.standardWeeklyRegeneration)", type: .wholeNumber,
              description: "Amount condition increases when sitting out a game"),
        .init(name: "effectivenesFactor", displayValue: "\(config.condition.effectivenesFactor)", type: .wholeNumber,
              description: "Factor by which loss of condition decreases ratings")

    ]
}

private func teamAiSettings(_ config: Configuration) -> [DebugMenuViewController.Model.Setting] {
    return [
        .init(name: "minConditionForSub", displayValue: "\(config.teamAI.minConditionForSub)", type: .wholeNumber,
              description: "Condition level where AI will always sub, if possible"),
        .init(name: "maxConditionForSub", displayValue: "\(config.teamAI.maxConditionForSub)", type: .wholeNumber,
              description: "Condition level where AI will consider subbing")

    ]
}

private func injurySettings(_ config: Configuration) -> [DebugMenuViewController.Model.Setting] {
    return [
        .init(name: "injuryChanceCondition1", displayValue: "\(config.injury.injuryChanceCondition1)", type: .wholeNumber,
              description: "Chance of injury when condition in 1-19"),
        .init(name: "injuryChanceCondition20", displayValue: "\(config.injury.injuryChanceCondition20)", type: .wholeNumber,
              description: "Chance of injury when condition in 20-39"),
        .init(name: "injuryChanceCondition40", displayValue: "\(config.injury.injuryChanceCondition40)", type: .wholeNumber,
              description: "Chance of injury when condition in 40-59"),
        .init(name: "injuryChanceCondition60", displayValue: "\(config.injury.injuryChanceCondition60)", type: .wholeNumber,
              description: "Chance of injury when condition in 60-79"),
        .init(name: "injuryChanceCondition80", displayValue: "\(config.injury.injuryChanceCondition80)", type: .wholeNumber,
              description: "Chance of injury when condition in 80-100"),
        .init(name: "conditionUponRecovery", displayValue: "\(config.injury.conditionUponRecovery)", type: .wholeNumber,
              description: "Condition level after recovering from injury")

    ]
}
