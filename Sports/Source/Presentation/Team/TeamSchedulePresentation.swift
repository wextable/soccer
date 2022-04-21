//
//  TeamSchedulePresentation.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import Foundation

extension TeamScheduleViewController.Model {

    init(team: Team, in league: League) {
        var games: [Game] = []
        for week in league.schedule {
            if let game = week.first(where: { $0.homeTeamId == team.id || $0.awayTeamId == team.id }) {
                games.append(game)
            }
        }
        self.init(title: "\(team.name) Schedule",
                  teamGameScheduleModels: TeamScheduleViewController.Model.teamGameScheduleModels(
                    games: games,
                    in: league)
        )
    }

    static func teamGameScheduleModels(games: [Game], in league: League) -> [TeamGameScheduleView.Model] {
        var models: [TeamGameScheduleView.Model] = []
        for i in 0..<games.count {
            models.append(.init(game: games[i], in: league))
        }
        return models
    }
}

extension TeamGameScheduleView.Model {

    init(game: Game, in league: League) {
        let away = league.team(withId: game.awayTeamId)
        let home = league.team(withId: game.homeTeamId)
        var score = "vs."
        if game.state == .fullTime {
            score = "\(game.awayScore) - \(game.homeScore)"
        }

        self.init(id: game.id,
                  awayRanking: " ",
                  awayTeamModel: .init(team: away),
                  score: score,
                  homeRanking: " ",
                  homeTeamModel: .init(team: home))
    }
}
