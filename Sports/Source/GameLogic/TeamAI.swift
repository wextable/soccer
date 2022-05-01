//
//  TeamAI.swift
//  Sports
//
//  Created by Wesley St. John on 4/27/22.
//

import Foundation

struct TeamAI {

    static func setStartingLineup(for team: Team) {
        team.starters.forEach { $0.isStarting = false }

        let keeper = chooseStartingKeeper(for: team)
        keeper.isStarting = true
        let others = chooseOtherStarters(from: team)
        others.forEach { $0.isStarting = true }
    }
}

extension TeamAI {
    private static func chooseStartingKeeper(for team: Team) -> Player {
        // filter by condition
        let conditionThreshold = Int.random(
            in: GameConfig.TeamAI.minConditionForSub...GameConfig.TeamAI.maxConditionForSub
        )
        let fitPlayers = team.keepers.filter { $0.condition > conditionThreshold }

        // fallback
        guard !fitPlayers.isEmpty else {
            return fitPlayers.sorted(by: { $0.condition > $1.condition })[0]
        }

        // sort by ratings.overall
        let keepers = fitPlayers.sorted { $0.overallRating >= $1.overallRating }

        return keepers[0]
    }

    private static func chooseOtherStarters(from team: Team) -> [Player] {

        var chosenPlayers: [Player] = []
        var remainingPlayers = team.players.filter { $0.position != .keeper }

        for _ in 1...GameConfig.TeamMakeup.numStartersPerTeam-1 {
            let conditionThreshold = Int.random(
                in: GameConfig.TeamAI.minConditionForSub...GameConfig.TeamAI.maxConditionForSub
            )
            
            // filter by condition
            let fitPlayers = remainingPlayers.filter {
                $0.condition > conditionThreshold
            }.sorted {
                $0.overallRating >= $1.overallRating
            }

            var chosenPlayer: Player
            if fitPlayers.isEmpty {
                chosenPlayer = remainingPlayers.sorted(by: { $0.condition > $1.condition })[0]
            } else {
                chosenPlayer = fitPlayers[0]
            }
            chosenPlayers.append(chosenPlayer)
            remainingPlayers = remainingPlayers.filter { $0.id != chosenPlayer.id }
        }

        return chosenPlayers
    }
}
