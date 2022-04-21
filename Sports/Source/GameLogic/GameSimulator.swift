//
//  GameSimulator.swift
//  Sports
//
//  Created by Wesley St. John on 12/23/21.
//

import Foundation
import GameplayKit

class GameSimulator {

    static func simulateGame(_ game: Game, homeTeam: Team, awayTeam: Team) {

        let homeScore = homeTeam.scoringRating
//        print("OFF team \(homeTeam.name): \(homeScore)")

        let awayDef = awayTeam.defensiveRating
//        print("DEF team \(awayTeam.name): \(awayDef)")

        let awayScore = awayTeam.scoringRating
//        print("OFF team \(awayTeam.name): \(awayScore)")

        let homeDef = homeTeam.defensiveRating
//        print("DEF team \(homeTeam.name): \(homeDef)")

        let homeDiff = homeScore - awayDef
        let awayDiff = awayScore - homeDef

        // -15: -1
        // -10: -0.33
        // -5: 0.33
        // 0: 1
        // 5: 1.667
        // 10: 2.33
        // 15: 3
        // y = mx + b
        // y = 4x/30 + 1
        let homeGoalStd = Double(homeDiff) / 7.5 + 1.2
//        print("homeGoalStd = \(homeGoalStd)")

        let awayGoalStd = Double(awayDiff) / 7.5 + 1.0
//        print("awayGoalStd = \(awayGoalStd)")

        let halfSpan = 300
        let random = GKRandomSource()
        let scoreDistribution = GKGaussianDistribution(randomSource: random, lowestValue: -halfSpan, highestValue: halfSpan)

        // Roll the dice...
        let homeRoll = Double(scoreDistribution.nextInt()) / 100.0
        let numHomeGoals = max(0, Int((homeGoalStd + homeRoll).rounded()))

        let awayRoll = Double(scoreDistribution.nextInt()) / 100.0
        let numAwayGoals = max(0, Int((awayGoalStd + awayRoll).rounded()))

        var shots: [Shot] = []
        var shotMinutes: [Int] = (0..<numHomeGoals).map { _ in .random(in: 1...90) }.sorted()
        for i in 0..<numHomeGoals {
            let shooter = selectGoalScorer(from: homeTeam)
            let passer = selectGoalAssister(from: homeTeam, scorer: shooter)
            let keeper = selectGoalKeeper(from: awayTeam)
            var type = Shot.ShotType.regular
            if passer == nil && Int.random(in: 0..<100) < 15 {
                type = .penalty
            }
            shots.append(Shot(type: type,
                              result: .goal,
                              shooter: shooter,
                              passer: passer,
                              keeper: keeper,
                              minute: shotMinutes[i],
                              isForHomeTeam: true))
        }

        shotMinutes = (0..<numAwayGoals).map { _ in .random(in: 1...90) }.sorted()
        for i in 0..<numAwayGoals {
            let shooter = selectGoalScorer(from: awayTeam)
            let passer = selectGoalAssister(from: awayTeam, scorer: shooter)
            let keeper = selectGoalKeeper(from: homeTeam)
            var type = Shot.ShotType.regular
            if passer == nil && Int.random(in: 0..<100) < 15 {
                type = .penalty
            }
            shots.append(Shot(type: type,
                              result: .goal,
                              shooter: shooter,
                              passer: passer,
                              keeper: keeper,
                              minute: shotMinutes[i],
                              isForHomeTeam: false))
        }

        let numHomeMisses: Int
        switch homeTeam.scoringRating {
        case 85...100: numHomeMisses = Int.random(in: 5...12)
        case 80..<85: numHomeMisses = Int.random(in: 4...10)
        case 75..<80: numHomeMisses = Int.random(in: 3...8)
        case 70..<75: numHomeMisses = Int.random(in: 2...6)
        default: numHomeMisses = Int.random(in: 1...4)
        }
        shotMinutes = (0..<numHomeMisses).map { _ in .random(in: 1...90) }.sorted()
        for i in 0..<numHomeMisses {
            let shot = shot(attackingTeam: homeTeam,
                            defendingTeam: awayTeam,
                            minute: shotMinutes[i],
                            isForHomeTeam: true)
            shots.append(shot)
        }

        let numAwayMisses: Int
        switch awayTeam.scoringRating {
        case 85...100: numAwayMisses = Int.random(in: 5...12)
        case 80..<85: numAwayMisses = Int.random(in: 4...10)
        case 75..<80: numAwayMisses = Int.random(in: 3...8)
        case 70..<75: numAwayMisses = Int.random(in: 2...6)
        default: numAwayMisses = Int.random(in: 1...4)
        }
        shotMinutes = (0..<numAwayMisses).map { _ in .random(in: 1...90) }.sorted()
        for i in 0..<numAwayMisses {
            let shot = shot(attackingTeam: awayTeam,
                            defendingTeam: homeTeam,
                            minute: shotMinutes[i],
                            isForHomeTeam: false)
            shots.append(shot)
        }

        game.homeScore = numHomeGoals
        game.awayScore = numAwayGoals
        game.shots = shots.sorted { $0.minute < $1.minute }
        game.state = .fullTime
    }
}

extension GameSimulator {

    private static func shot(attackingTeam: Team,
                             defendingTeam: Team,
                             minute: Int,
                             isForHomeTeam: Bool) -> Shot {
        let shooter = selectGoalScorer(from: attackingTeam)
        let passer = selectGoalAssister(from: attackingTeam, scorer: shooter)
        let keeper = selectGoalKeeper(from: defendingTeam)
        var type = Shot.ShotType.regular
        if passer == nil && Int.random(in: 0..<100) < 5 {
            type = .penalty
        }
        var result = Shot.ShotResult.miss
        if Int.random(in: 0..<100) < (keeper.ratings.goalkeeping - 50) {
            result = .save
        }
        return Shot(type: type,
                    result: result,
                    shooter: shooter,
                    passer: passer,
                    keeper: keeper,
                    minute: minute,
                    isForHomeTeam: isForHomeTeam)
    }

    private static func selectGoalScorer(from team: Team) -> Player {

        var totalTeamRating = 0.0
        for player in team.players {
            let rating = Double(player.ratings.overallScoring - 50)
            switch player.position {
            case .keeper: break
            case .defender: totalTeamRating += rating * 1.5
            case .midfielder: totalTeamRating += rating * 2
            case .forward: totalTeamRating += rating * 2.5
            }
        }

        var randomRating = Double(Int.random(in: 0...Int(totalTeamRating)))
        for player in team.players {
            let rating = Double(player.ratings.overallScoring - 50)
            var playerRating = 0.0
            switch player.position {
            case .keeper: break
            case .defender: playerRating = rating * 1.5
            case .midfielder: playerRating = rating * 2
            case .forward: playerRating = rating * 2.5
            }
            if randomRating <= playerRating {
                return player
            }
            randomRating -= playerRating
        }

        return team.players[0]
    }

    private static func selectGoalAssister(from team: Team, scorer: Player) -> Player? {
        guard Int.random(in: 0..<100) < 60 else {
            return nil
        }

        return selectGoalContributor(from: team, excluding: [scorer])
    }

    static func selectGoalContributor(from team: Team, excluding: [Player]) -> Player? {

        let remainingPlayers = team.players.filter {
            return !excluding.contains($0)
        }

        var totalTeamRating = 0
        for player in remainingPlayers {
            switch player.position {
            case .keeper: break
            case .defender: totalTeamRating += player.ratings.overallAssist
            case .midfielder: totalTeamRating += player.ratings.overallAssist * 2
            case .forward: totalTeamRating += player.ratings.overallAssist * 3
            }
        }

        var randomRating = Int.random(in: 0...totalTeamRating)
        for player in remainingPlayers {
            var playerRating = 0
            switch player.position {
            case .keeper: break
            case .defender: playerRating = player.ratings.overallAssist
            case .midfielder: playerRating = player.ratings.overallAssist * 2
            case .forward: playerRating = player.ratings.overallAssist * 3
            }
            if randomRating <= playerRating {
                return player
            }
            randomRating -= playerRating
        }

        return nil
    }

    private static func selectGoalKeeper(from team: Team) -> Player {
        return team.keepers[0]
    }

    static func selectGoalDefender(from team: Team, excluding: [Player]) -> Player? {

        let remainingPlayers = team.players.filter {
            return !excluding.contains($0)
        }

        var totalTeamRating = 0
        for player in remainingPlayers {
            switch player.position {
            case .keeper: break
            case .defender: totalTeamRating += player.ratings.overallDefensive * 3
            case .midfielder: totalTeamRating += player.ratings.overallDefensive * 2
            case .forward: totalTeamRating += player.ratings.overallDefensive
            }
        }

        var randomRating = Int.random(in: 0...totalTeamRating)
        for player in remainingPlayers {
            var playerRating = 0
            switch player.position {
            case .keeper: break
            case .defender: playerRating = player.ratings.overallDefensive * 3
            case .midfielder: playerRating = player.ratings.overallDefensive * 2
            case .forward: playerRating = player.ratings.overallDefensive
            }
            if randomRating <= playerRating {
                return player
            }
            randomRating -= playerRating
        }

        return nil
    }
}
