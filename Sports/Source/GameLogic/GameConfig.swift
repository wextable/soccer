//
//  GameConfig.swift
//  Sports
//
//  Created by Wesley St. John on 4/24/22.
//

import Foundation

struct GameConfig {

    struct TeamMakeup {
        static let numStartersPerTeam = 11
        static let maxNumStartingKeepersPerTeam = 1
        static let maxNumStartingPositionalPerTeam = 4
        static let maxNumKeepersPerTeam = 2
        static let maxNumPositionalPerTeam = 6
        static var maxNumPlayersPerTeam: Int {
            return maxNumKeepersPerTeam + maxNumPositionalPerTeam * 3
        }
    }

    struct XP {
        static let requiredBaseXP = 100
        static let requiredXpPerLevel = 10

        static let standardXpBump = 10
        static let goalXpBump = 5
        static let assistXpBump = 2
        static let saveXpBump = 2
        static let keeperCleanSheetXpBump = 2
        static let defenderCleanSheetXpBump = 3

        static let levelUpAmountSpeed = 5
        static let levelUpAmountShooting = 5
        static let levelUpAmountPassing = 5
        static let levelUpAmountDribbling = 5
        static let levelUpAmountDefending = 3
        static let levelUpAmountGoalkeeping = 3
    }

    struct Condition {
        static let standardGameFatigue = 3
        static let standardWeeklyRegeneration = 15

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
        static let effectivenesFactor = 0.1

    }

    struct TeamAI {
        static let minConditionForSub = 25
        static let maxConditionForSub = 60
    }

    struct Injury {
        static let conditionUponRecovery = 50
    }
}
