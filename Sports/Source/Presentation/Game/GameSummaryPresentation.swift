//
//  GameSummaryPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 2/26/22.
//

import Foundation

extension GameSummaryViewController.Model {

    init(game: Game,
         in league: League,
         dataStore: DataStore,
         canPlay: Bool = false,
         recordAdjustment: RecordAdjustment = .init()) {

        let title: String
        switch game.state {
        case .preGame: title = "Preview"
        case .halftime: title = "Halftime"
        case .fullTime: title = "Full Time"
        }

        let away = league.team(withId: game.awayTeamId)
        let awayWins = away.wins + recordAdjustment.awayWinAdjustment
        let awayDraws = away.draws + recordAdjustment.awayTieAdjustment
        let awayLosses = away.losses + recordAdjustment.awayLossAdjustment
        var awayRankName = away.name
        if let awayRank = league.rankedTeams.firstIndex(where: { $0.id == away.id }) {
            awayRankName = "#\(awayRank + 1) \(awayRankName)"
        }
        let awayName = "\(awayRankName) (\(awayWins)-\(awayDraws)-\(awayLosses))"

        let home = league.team(withId: game.homeTeamId)
        let homeWins = home.wins + recordAdjustment.homeWinAdjustment
        let homeDraws = home.draws + recordAdjustment.homeTieAdjustment
        let homeLosses = home.losses + recordAdjustment.homeLossAdjustment
        var homeRankName = home.name
        if let homeRank = league.rankedTeams.firstIndex(where: { $0.id == home.id }) {
            homeRankName = "#\(homeRank + 1) \(homeRankName)"
        }
        let homeName = "\(homeRankName) (\(homeWins)-\(homeDraws)-\(homeLosses))"

        var awayOffRatingOutOfFive: Double?
        var homeOffRatingOutOfFive: Double?
        var awayDefRatingOutOfFive: Double?
        var homeDefRatingOutOfFive: Double?
        var awaySeasonStats: String?
        var homeSeasonStats: String?
        if game.state == .preGame {
            awayOffRatingOutOfFive = away.offensiveStarRating
            homeOffRatingOutOfFive = home.offensiveStarRating
            awayDefRatingOutOfFive = away.defensiveStarRating
            homeDefRatingOutOfFive = home.defensiveStarRating

            let awayPlus = (away.goalsFor - away.goalsAgainst) > 0 ? "+" : ""
            awaySeasonStats = "GF: \(away.goalsFor) GA: \(away.goalsAgainst) GD: \(awayPlus)\(away.goalsFor - away.goalsAgainst)"
            let homePlus = (home.goalsFor - home.goalsAgainst) > 0 ? "+" : ""
            homeSeasonStats = "GF: \(home.goalsFor) GA: \(home.goalsAgainst) GD: \(homePlus)\(home.goalsFor - home.goalsAgainst)"
        }

        let awayPlayers = GameSummaryViewController.Model.topPlayers(numPlayers: 4,
                                                                     from: away)
        let awayPlayerCardModels = awayPlayers.map {
            PlayerCardView.Model(player: $0, team: away, dataStore: dataStore)
        }
        let homePlayers = GameSummaryViewController.Model.topPlayers(numPlayers: 4,
                                                                     from: home)
        let homePlayerCardModels = homePlayers.map {
            PlayerCardView.Model(player: $0, team: home, dataStore: dataStore)
        }

        var score: String?
        var awayGoalsText: String?
        var homeGoalsText: String?
        if game.state != .preGame {
            score = "\(game.awayScore) - \(game.homeScore)"
            awayGoalsText = game.awayGoals
                .map { "\($0.shooter.fullName) (\($0.minute)')" }
                .joined(separator: "\n")
            homeGoalsText = game.homeGoals
                .map { "\($0.shooter.fullName) (\($0.minute)')" }
                .joined(separator: "\n")
        }

        self.init(title: title,
                  awayLogo: away.icon,
                  awayName: awayName,
                  homeName: homeName,
                  awayOffRatingOutOfFive: awayOffRatingOutOfFive,
                  homeOffRatingOutOfFive: homeOffRatingOutOfFive,
                  awayDefRatingOutOfFive: awayDefRatingOutOfFive,
                  homeDefRatingOutOfFive: homeDefRatingOutOfFive,
                  awaySeasonStats: awaySeasonStats,
                  homeSeasonStats: homeSeasonStats,
                  homeLogo: home.icon,
                  awayPlayerCardModels: awayPlayerCardModels,
                  homePlayerCardModels: homePlayerCardModels,
                  score: score,
                  awayGoalsText: awayGoalsText,
                  homeGoalsText: homeGoalsText,
                  shouldShowPlayGameButton: canPlay && game.state == .preGame,
                  shouldShowHighlightsButton: game.state == .fullTime,
                  shouldAutoDismiss: game.state == .halftime)
    }

    private static func topPlayers(numPlayers: Int,
                                   from team: Team) -> [Player] {
        let topPlayers = team.players.sorted { $0.ratings.overall > $1.ratings.overall }
        let maxNumPlayers = min(numPlayers, topPlayers.count)
        return Array(topPlayers.prefix(maxNumPlayers))
    }
}

extension PlayerCardView.Model {
    init(player: Player, team: Team, dataStore: DataStore) {
        let stats: String
        switch player.position {
        case .keeper: stats = "S: \(player.stats.saves), CS: \(player.stats.cleanSheets)"
        default: stats = "G: \(player.stats.goals), A: \(player.stats.assists)"
        }
        self.init(id: player.id,
                  name: player.firstInitialAndLastName,
                  image: dataStore.getPlayerImage(player, from: team),
                  position: player.position,
                  ratingOutOfFive: player.ratings.overallStarRating,
                  stats: stats)
    }
}
