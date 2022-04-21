//
//  LeagueSchedulePresentation.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import Foundation

extension LeagueScheduleViewController.Model {

    init(league: League, week: Int) {
        var games: [Game] = []
        if week < league.schedule.count {
            games = league.schedule[week]
        }
        self.init(title: "\(league.name) Schedule - week \(week + 1)",
                  gameScheduleModels: LeagueScheduleViewController.Model.gameScheduleModels(
                    games: games,
                    in: league)
        )
    }

    static func gameScheduleModels(games: [Game], in league: League) -> [GameScheduleView.Model] {
        var models: [GameScheduleView.Model] = []
        for i in 0..<games.count {
            models.append(.init(game: games[i], in: league))
        }
        return models
    }
}

extension GameScheduleView.Model {

    init(game: Game, in league: League) {
        let away = league.team(withId: game.awayTeamId)
        let home = league.team(withId: game.homeTeamId)
        var score = "vs."
        if game.state == .fullTime {
            score = "\(game.awayScore) - \(game.homeScore)"
        }

        self.init(id: game.id,
                  awayRanking: " ",
                  awayTeamModel: .init(icon: away.icon,
                                       text: away.name),
                  score: score,
                  homeRanking: " ",
                  homeTeamModel: .init(icon: home.icon,
                                       text: home.name))
    }
}
