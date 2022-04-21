//
//  LeagueDataSource.swift
//  Sports
//
//  Created by Wesley St. John on 12/23/21.
//

import Foundation
import Combine

class LeagueDataSource {
    @Published final private(set) var data: Data
    let dataStore: DataStore

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        data = .init(league: .init())
    }

    func setLeague(_ league: League) {
        data = .init(league: league)
        dataStore.saveLeague(league)
    }

    func simulateWeek() {
        guard data.league.currentWeek < data.league.schedule.count else { return }

        for game in data.league.schedule[data.league.currentWeek] {
            let home = data.league.team(withId: game.homeTeamId)
            let away = data.league.team(withId: game.awayTeamId)
            GameSimulator.simulateGame(game, homeTeam: home, awayTeam: away)
            saveGame(game)
        }
        data.league.currentWeek += 1
        dataStore.saveLeague(data.league)
    }

    func saveGame(_ game: Game) {
        guard let home = data.league.teams.first(where: { $0.id == game.homeTeamId }),
              let away = data.league.teams.first(where: { $0.id == game.awayTeamId }) else {
                  return
              }

        let standardXpBump = 10
        let goalXpBump = 5
        let assistXpBump = 2
        let saveXpBump = 2
        let cleanSheetXpBump = 2

        if game.homeScore > game.awayScore {
            home.wins += 1
            away.losses += 1
        } else if game.awayScore > game.homeScore {
            away.wins += 1
            home.losses += 1
        } else {
            home.draws += 1
            away.draws += 1
        }

        home.goalsFor += game.homeScore
        home.goalsAgainst += game.awayScore
        away.goalsFor += game.awayScore
        away.goalsAgainst += game.homeScore

        for homeGoal in game.homeGoals {
            guard let player = home.players.first(where: { $0.id == homeGoal.shooter.id }) else {
                continue
            }
            player.stats.goals += 1
            player.increaseXp(by: goalXpBump)
            if let assisterId = homeGoal.passer?.id,
               let assister = home.players.first(where: { $0.id == assisterId }) {
                assister.stats.assists += 1
                assister.increaseXp(by: assistXpBump)
            }
        }

        for awayGoal in game.awayGoals {
            guard let player = away.players.first(where: { $0.id == awayGoal.shooter.id }) else {
                continue
            }
            player.stats.goals += 1
            player.increaseXp(by: goalXpBump)
            if let assisterId = awayGoal.passer?.id,
               let assister = away.players.first(where: { $0.id == assisterId }) {
                assister.stats.assists += 1
                assister.increaseXp(by: assistXpBump)
            }
        }

        for shot in game.shots.filter({ $0.result == .save }) {
            if shot.isForHomeTeam,
               let player = away.players.first(where: { $0.position == .keeper }) {
                player.stats.saves += 1
                player.increaseXp(by: saveXpBump)
            } else if !shot.isForHomeTeam,
                let player = home.players.first(where: { $0.position == .keeper }) {
                player.stats.saves += 1
                player.increaseXp(by: saveXpBump)
            }
        }

        if game.homeGoals.isEmpty,
           let player = away.players.first(where: { $0.position == .keeper }) {
            player.stats.cleanSheets += 1
            player.increaseXp(by: cleanSheetXpBump)
        }

        if game.awayGoals.isEmpty,
           let player = home.players.first(where: { $0.position == .keeper }) {
            player.stats.cleanSheets += 1
            player.increaseXp(by: cleanSheetXpBump)
        }


        for player in home.players {
            player.increaseXp(by: standardXpBump)
        }
        for player in away.players {
            player.increaseXp(by: standardXpBump)
        }

    }
}

extension LeagueDataSource {
    struct Data {
        var league: League        
    }
}

extension League {

    var rankedTeams: [Team] {
        return teams.sorted {
            if $0.points > $1.points {
                return true
            } else if $1.points > $0.points {
                return false
            } else {
                return $0.goalsFor - $0.goalsAgainst > $1.goalsFor - $1.goalsAgainst
            }
        }
    }
}
