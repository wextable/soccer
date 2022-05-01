//
//  LeagueFactory.swift
//  Sports
//
//  Created by Wesley St. John on 12/22/21.
//

import Foundation

class LeagueFactory {

    static func makeLeague(numTeams: Int) -> League {
        let teams = makeTeams(numTeams: numTeams)
        let teamIds = teams.map { $0.id }
        let pairings = Scheduler.seasonPairings(teamIds: teamIds.shuffled())
        var schedule: [[Game]] = []
        var weekNumber = 0
        for week in pairings {
            var weeklyGames: [Game] = []
            for matchup in week {
                if let homeId = matchup.0,
                   let awayId = matchup.1 {
                    let game = Game(id: UUID().uuidString,
                                    homeTeamId: homeId,
                                    awayTeamId: awayId,
                                    week: weekNumber)
                    weeklyGames.append(game)
                }
            }
            schedule.append(weeklyGames)
            weekNumber += 1
        }
        return League(id: UUID().uuidString,
                      name: "My League",
                      teams: teams,
                      schedule: schedule)
    }

}

extension LeagueFactory {

    private static func makeTeams(numTeams: Int) -> [Team] {
        var allPlayers = makePlayerPool(numTeams: numTeams)
        let allTeams = makeTeamPool(numTeams: numTeams)

        var round = 1
        while !areRostersFull(for: allTeams) {

            var numTeamsDrafting = numTeams
            if round < 3 {
                numTeamsDrafting = Int(Double(numTeams) * 0.3)
            } else if round < 4 {
                numTeamsDrafting = Int(Double(numTeams) * 0.6)
            } else if round < 6 {
                numTeamsDrafting = Int(Double(numTeams) * 0.75)
            }

            for i in 0..<numTeamsDrafting {

                guard let draftedPlayer = draftPlayer(for: allTeams[i], from: allPlayers) else {
                    continue
                }
                allPlayers.removeAll { $0 == draftedPlayer }

                draftedPlayer.teamId = allTeams[i].id
                allTeams[i].players.append(draftedPlayer)
            }

            round += 1
        }

        for i in 0..<numTeams {
            allTeams[i].players = allTeams[i].players.sorted {
                if $0.position.ordinalValue < $1.position.ordinalValue {
                    return true
                } else if $0.position.ordinalValue > $1.position.ordinalValue {
                    return false
                } else if $0.overallStarRating > $1.overallStarRating {
                    return true
                } else if $0.overallStarRating < $1.overallStarRating {
                    return false
                } else {
                    return $0.overallStarRatingPotential > $1.overallStarRatingPotential
                }
            }
        }

        return allTeams
    }

    private static func makePlayerPool(numTeams: Int) -> [Player] {
        var positions: [Position] = []
        var pool: [Player] = []
        for _ in 0..<numTeams * GameConfig.TeamMakeup.maxNumKeepersPerTeam { positions.append(.keeper) }
        for _ in 0..<numTeams * GameConfig.TeamMakeup.maxNumPositionalPerTeam { positions.append(.defender) }
        for _ in 0..<numTeams * GameConfig.TeamMakeup.maxNumPositionalPerTeam { positions.append(.midfielder) }
        for _ in 0..<numTeams * GameConfig.TeamMakeup.maxNumPositionalPerTeam { positions.append(.forward) }

        for pos in positions {
            let p = PlayerFactory.makePlayer(position: pos)
            pool.append(p)
        }
        let sortedPool = pool.sorted {
            $0.overallRating >= $1.overallRating
        }
        return sortedPool
    }

    private static func makeTeamPool(numTeams: Int) -> [Team] {
        var teams: [Team] = []
        for i in 0..<numTeams {
            teams.append(TeamFactory.makeTeam(index: i))
        }
        return teams
    }

    private static func areRostersFull(for teams: [Team]) -> Bool {
        return !teams.contains(where: {
            $0.players.count < GameConfig.TeamMakeup.maxNumPlayersPerTeam
        })
    }

    private static func draftPlayer(for team: Team, from players: [Player]) -> Player? {
        guard team.players.count < GameConfig.TeamMakeup.numStartersPerTeam else {
            return draftReservePlayer(for: team, from: players)
        }

        let isLastPlayer = team.players.count == GameConfig.TeamMakeup.numStartersPerTeam - 1

        let startingPlayer =  players.first { bestPlayer in
            let existing = team.players.filter { $0.position == bestPlayer.position }
            switch bestPlayer.position {
            case .keeper: return existing.count < GameConfig.TeamMakeup.maxNumStartingKeepersPerTeam
            default:
                if isLastPlayer {
                    return existing.count < GameConfig.TeamMakeup.maxNumStartingPositionalPerTeam
                } else {
                    return existing.count < GameConfig.TeamMakeup.maxNumStartingPositionalPerTeam - 1
                }
            }
        }

        startingPlayer?.isStarting = true
        return startingPlayer
    }

    private static func draftReservePlayer(for team: Team, from players: [Player]) -> Player? {
        guard team.players.count < GameConfig.TeamMakeup.maxNumPlayersPerTeam else { return nil }

        return players.first { bestPlayer in
            let existing = team.players.filter { $0.position == bestPlayer.position }
            switch bestPlayer.position {
            case .keeper: return existing.count < GameConfig.TeamMakeup.maxNumKeepersPerTeam
            default: return existing.count < GameConfig.TeamMakeup.maxNumPositionalPerTeam
            }
        }
    }
}
