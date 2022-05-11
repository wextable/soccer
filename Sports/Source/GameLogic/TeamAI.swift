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

    static func addNewInjuries(for teams: [Team]) {
        for team in teams {
            let healthyStarters = team.starters
                .filter({ !$0.isInjured })
                .sorted { $0.condition < $1.condition }
            let numHealthyKeepers = team.players.filter({
                $0.position == .keeper && !$0.isInjured
            }).count

            if let player = healthyStarters.first(where: {
                if $0.position == .keeper && numHealthyKeepers == 1 {
                    // Always leave at least 1 keeper uninjured
                    return false
                }
                return TeamAI.didPlayerGetInjured($0)
            }) {

                var cause: String = ""
                if let lastGame = team.schedule.last(where: { $0?.state == .fullTime }),
                   let opponentId = lastGame?.homeTeamId == team.id ? lastGame?.awayTeamId : lastGame?.homeTeamId,
                   let opposingTeam = teams.first(where: { $0.id == opponentId }),
                   let opposingPlayer = opposingTeam.starters.randomElement() {

                    let causes = GameConfig.config.injury.causes
                    cause = "\(opposingTeam.name)'s \(opposingPlayer.fullName) \(causes.randomElement()!)"
                }

                player.addInjury(causeDescription: cause)
            }
        }
    }

    static func didPlayerGetInjured(_ player: Player) -> Bool {
        let injuryChance: Int
        switch player.condition {
        case Int.min...0: injuryChance = 100
        case 1..<20: injuryChance = GameConfig.config.injury.injuryChanceCondition1
        case 20..<40: injuryChance = GameConfig.config.injury.injuryChanceCondition20
        case 40..<60: injuryChance = GameConfig.config.injury.injuryChanceCondition40
        case 60..<80: injuryChance = GameConfig.config.injury.injuryChanceCondition60
        case 80..<100: injuryChance = GameConfig.config.injury.injuryChanceCondition80
        default: injuryChance = 0
        }

        let roll = Int.random(in: 1...100)
        return roll <= injuryChance
    }
}

extension TeamAI {
    private static func chooseStartingKeeper(for team: Team) -> Player {
        // filter by condition
        let conditionThreshold = Int.random(
            in: GameConfig.config.teamAI.minConditionForSub...GameConfig.config.teamAI.maxConditionForSub
        )
        let fitPlayers = team.keepers.filter { $0.condition > conditionThreshold }

        // fallback
        guard !fitPlayers.isEmpty else {
            return team.keepers.sorted(by: { $0.condition > $1.condition })[0]
        }

        // sort by ratings.overall
        let keepers = fitPlayers.sorted { $0.overallRating >= $1.overallRating }

        return keepers[0]
    }

    private static func chooseOtherStarters(from team: Team) -> [Player] {

        var chosenPlayers: [Player] = []
        var remainingPlayers = team.players.filter { $0.position != .keeper }

        for _ in 1...GameConfig.config.teamMakeup.numStartersPerTeam-1 {
            let conditionThreshold = Int.random(
                in: GameConfig.config.teamAI.minConditionForSub...GameConfig.config.teamAI.maxConditionForSub
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
