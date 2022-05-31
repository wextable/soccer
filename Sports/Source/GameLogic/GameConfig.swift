//
//  GameConfig.swift
//  Sports
//
//  Created by Wesley St. John on 4/24/22.
//

import Foundation

struct GameConfig {

    private static let `default` = Configuration()
    private static var stored: Configuration?
    private static let userDefaults = UserDefaults(suiteName: "GameConfig")
    private static let userDefaultsKey = "GameConfigObject"

    static var config: Configuration {
        return stored ?? `default`
    }

    static func resetToDefaultConfiguration() {
        setCustomConfiguration(nil)
    }

    static func setCustomConfiguration(_ config: Configuration?) {
        defer {
            stored = config
        }

        guard let config = config else {
            userDefaults?.set(nil, forKey: userDefaultsKey)
            return
        }

        if let data = try? JSONEncoder().encode(config) {
            userDefaults?.set(data, forKey: userDefaultsKey)
        }
    }

    static func loadStoredConfig() {
        if let data = userDefaults?.object(forKey: userDefaultsKey) as? Data,
           let override = try? JSONDecoder().decode(Configuration.self, from: data) {
            stored = override
        }
    }
}

struct Configuration: Codable {
    var teamMakeup = TeamMakeup()
    var gameAI = GameAI()
    var xp = XP()
    var condition = Condition()
    var teamAI = TeamAI()
    var injury = Injury()
}

extension Configuration {

    struct TeamMakeup: Codable {
        var numStartersPerTeam = 11
        var maxNumStartingKeepersPerTeam = 1
        var maxNumStartingPositionalPerTeam = 4
        var maxNumKeepersPerTeam = 2
        var maxNumPositionalPerTeam = 6
        var maxNumPlayersPerTeam: Int {
            return maxNumKeepersPerTeam + maxNumPositionalPerTeam * 3
        }
    }

    struct GameAI: Codable {
        var ratingDiffPerGoal = 7.5
        var homeFieldAdvantage = 0.25
        var halfWidthGoalBellCurve = 3.0
    }

    struct XP: Codable {
        var requiredBaseXP = 100
        var requiredXpPerLevel = 10

        var standardXpBump = 10
        var goalXpBump = 5
        var assistXpBump = 2
        var saveXpBump = 2
        var keeperCleanSheetXpBump = 2
        var defenderCleanSheetXpBump = 3

        var levelUpAmountSpeed = 5
        var levelUpAmountShooting = 5
        var levelUpAmountPassing = 5
        var levelUpAmountDribbling = 5
        var levelUpAmountDefending = 3
        var levelUpAmountGoalkeeping = 3
    }

    struct Condition: Codable {
        var standardGameFatigue = 3
        var standardWeeklyRegeneration = 15

        /*
         Cond   effectiveness   Rating
         100    100             90
         80     95             85.5
         60     90             81
         40     85              76.5
         20     80              72
         0      injured

         effectiveness = 100 - ((100-condition) * 0.25)
         effectiveRating = rating * effectiveness
         */
        var effectivenesFactor = 0.1

    }

    struct TeamAI: Codable {
        var minConditionForSub = 55
        var maxConditionForSub = 85
    }

    struct Injury: Codable {
        var injuryChanceCondition1 = 50
        var injuryChanceCondition20 = 25
        var injuryChanceCondition40 = 8
        var injuryChanceCondition60 = 3
        var injuryChanceCondition80 = 1

        var conditionUponRecovery = 75

        var causes = ["slid into him with a vengence.",
                      "fucked him up.",
                      "trod upon him.",
                      "head butted him.",
                      "elbowed him.",
                      "bit him with sharp teeth.",
                      "landed on him with his fat ass.",
                      "kicked him on purpose.",
                      "punched him.",
                      "pushed him down when the ref wasn't looking.",
                      "accidentally thrashed him.",
                      "went in for the low blow.",
                      "had his way with him, unfortunately.",
                      "was a naughty boy and hurt him.",
                      "just slapped him so hard, and for no good reason.",
                      "took him behind the woodshed after the game.",
                      "put antifreeze in his gatorade bottle.",
                      "called his mother a 'moistened bint', then kneed him.",
                      "pulled his hair and made him fall down, go boom."]
    }
}
