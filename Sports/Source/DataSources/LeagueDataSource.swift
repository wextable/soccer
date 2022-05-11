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

    func simulateSeason() {
        for _ in 0..<data.league.schedule.count {
            simulateWeek()
        }
    }

    func simulateWeek() {
        guard data.league.currentWeek < data.league.schedule.count else { return }

        for game in data.league.schedule[data.league.currentWeek] {
            let home = data.league.team(withId: game.homeTeamId)
            let away = data.league.team(withId: game.awayTeamId)
            GameSimulator.simulateGame(game, homeTeam: home, awayTeam: away)

            recordGameStats(game)

            if home.id == data.league.userTeamId {
                progressXp(for: home, from: game, isHomeTeam: true)
            } else if away.id == data.league.userTeamId {
                progressXp(for: away, from: game, isHomeTeam: false)
            }

            progressCondition(for: home)
            progressCondition(for: away)
        }

        advanceWeek()

        dataStore.saveLeague(data.league)
    }

    private func recordGameStats(_ game: Game) {
        guard let home = data.league.teams.first(where: { $0.id == game.homeTeamId }),
              let away = data.league.teams.first(where: { $0.id == game.awayTeamId }) else {
                  return
              }

        // Team record
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

        // Team goals
        home.goalsFor += game.homeScore
        home.goalsAgainst += game.awayScore
        away.goalsFor += game.awayScore
        away.goalsAgainst += game.homeScore

        // Home goals an assists
        for homeGoal in game.homeGoals {
            guard let player = home.players.first(where: { $0.id == homeGoal.shooter.id }) else {
                continue
            }
            player.stats.goals += 1
            if let assisterId = homeGoal.passer?.id,
               let assister = home.players.first(where: { $0.id == assisterId }) {
                assister.stats.assists += 1
            }
        }

        // Away goals an assists
        for awayGoal in game.awayGoals {
            guard let player = away.players.first(where: { $0.id == awayGoal.shooter.id }) else {
                continue
            }
            player.stats.goals += 1
            if let assisterId = awayGoal.passer?.id,
               let assister = away.players.first(where: { $0.id == assisterId }) {
                assister.stats.assists += 1
            }
        }

        // Saves
        for shot in game.shots.filter({ $0.result == .save }) {
            if shot.isForHomeTeam,
               let player = away.starters.first(where: { $0.position == .keeper }) {
                player.stats.saves += 1
            } else if !shot.isForHomeTeam,
                let player = home.starters.first(where: { $0.position == .keeper }) {
                player.stats.saves += 1
            }
        }

        // Home clean sheets
        if game.homeGoals.isEmpty,
           let player = away.starters.first(where: { $0.position == .keeper }) {
            player.stats.cleanSheets += 1
        }

        // Away clean sheets
        if game.awayGoals.isEmpty,
           let player = home.starters.first(where: { $0.position == .keeper }) {
            player.stats.cleanSheets += 1
        }
    }

    private func progressXp(for team: Team, from game: Game, isHomeTeam: Bool) {

        // XP for goals
        for goal in isHomeTeam ? game.homeGoals : game.awayGoals {
            guard let player = team.players.first(where: { $0.id == goal.shooter.id }) else {
                continue
            }

            player.increaseXp(by: GameConfig.config.xp.goalXpBump)
            if let assisterId = goal.passer?.id,
               let assister = team.players.first(where: { $0.id == assisterId }) {
                assister.increaseXp(by: GameConfig.config.xp.assistXpBump)
            }
        }

        // XP for saves
        let numSaves = game.shots.filter({
            $0.result == .save &&
            ((isHomeTeam && $0.isForHomeTeam) || (!isHomeTeam && !$0.isForHomeTeam))
        }).count

        if let player = team.starters.first(where: { $0.position == .keeper }) {
            player.increaseXp(by: GameConfig.config.xp.saveXpBump * numSaves)
        }

        // XP for clean sheet
        if (isHomeTeam && game.awayGoals.isEmpty) || (!isHomeTeam && game.homeGoals.isEmpty) {
            for player in team.starters {
                switch player.position {
                case .keeper:
                    player.increaseXp(by: GameConfig.config.xp.keeperCleanSheetXpBump)
                case .defender:
                    player.increaseXp(by: GameConfig.config.xp.defenderCleanSheetXpBump)
                default:
                    break
                }
            }
        }

        // XP for playing in the game
        for player in team.starters {
            player.increaseXp(by: GameConfig.config.xp.standardXpBump)
        }
    }

    private func progressCondition(for team: Team) {
        // Condition
        for player in team.players {
            if player.isStarting {
                player.decreaseCondition(by: GameConfig.config.condition.standardGameFatigue)
            } else if !player.isInjured {
                player.increaseCondition(by: GameConfig.config.condition.standardWeeklyRegeneration)
            }
        }
    }

    private func advanceWeek() {
        data.league.currentWeek += 1

        // Injuries!
        advanceInjuries()
        addNewInjuries()

        // AI starting lineups
        setStartingLineups()
    }

    private func advanceInjuries() {
        for team in data.league.teams {
            team.players.forEach {
                // Remove previously recovered injuries
                if $0.injury?.isRecovered == true {
                    $0.injury = nil                    
                }

                // Advance existing injuries
                $0.injury?.advanceWeek()
                if $0.injury?.isRecovered == true {
                    // For newly recovered injuries, heal the player
                    $0.condition = GameConfig.config.injury.conditionUponRecovery
                }
            }
        }
    }

    private func addNewInjuries() {
        TeamAI.addNewInjuries(for: data.league.teams)
    }

    private func setStartingLineups() {
        for team in data.league.teams {
            if team.id != data.league.userTeamId {
                TeamAI.setStartingLineup(for: team)
            }
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
            } else if $0.goalsFor - $0.goalsAgainst > $1.goalsFor - $1.goalsAgainst {
                return true
            } else {
                return $0.overallRating > $1.overallRating
            }
        }
    }
}
