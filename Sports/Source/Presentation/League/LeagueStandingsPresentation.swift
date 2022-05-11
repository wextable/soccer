//
//  LeagueStandingsPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import Foundation

extension LeagueStandingsViewController.Model {
    
    init(league: League) {
        self.init(title: "\(league.name) Standings",
                  teamStandingModels: LeagueStandingsViewController.Model.teamStandingModels(
                    teams: league.rankedTeams)
        )
    }

    static func teamStandingModels(teams: [Team]) -> [TeamStandingsView.Model] {
        var models: [TeamStandingsView.Model] = []
        for i in 0..<teams.count {
            models.append(.init(team: teams[i], rankIndex: i))
        }
        return models
    }
}


extension TeamStandingsView.Model {

    init(team: Team, rankIndex: Int) {

        self.init(id: team.id,
                  ranking: "\(rankIndex + 1)",
                  teamModel: .init(team: team),
                  wins: "\(team.wins)",
                  draws: "\(team.draws)",
                  losses: "\(team.losses)",
                  points: "\(team.points)",
                  goalsFor: "\(team.goalsFor)",
                  goalsAgainst: "\(team.goalsAgainst)",
                  goalDifferential: "\(team.goalsFor - team.goalsAgainst)",
                  offense: "\(team.scoringRating)",
                  defense: "\(team.defensiveRating)",
                  overall: "\(team.overallRating)"
        )
    }
}
