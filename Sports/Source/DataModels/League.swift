//
//  League.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import Foundation
import SwiftUI

class League: NSObject, Codable {
    let id: String
    let name: String
    let teams: [Team]
    let schedule: [[Game]]
    var currentWeek: Int = 0
    var userTeamId: String = ""

    override convenience init() {
        self.init(id: "", name: "", teams: [], schedule: [])
    }

    init(id: String,
         name: String,
         teams: [Team],
         schedule: [[Game]]) {
        self.id = id
        self.name = name
        self.teams = teams
        self.schedule = schedule

        super.init()

        for week in schedule {
            for game in week {
                let home = team(withId: game.homeTeamId)
                let away = team(withId: game.awayTeamId)
                home.schedule.append(game)
                away.schedule.append(game)
            }
        }
    }
}

extension League {
    var allPlayers: [Player] {
        var players: [Player] = []
        for t in teams {
            for p in t.players {
                players.append(p)
            }
        }
        return players
    }

    var userTeam: Team {
        return team(withId: userTeamId)
    }

    func team(withId id: String) -> Team {
        return teams.first(where: { $0.id == id })!
    }

    func player(withId id: String, onTeamId teamId: String) -> Player {
        let team = team(withId: teamId)
        return team.players.first(where: { $0.id == id })!
    }

    func player(withId id: String) -> Player? {
        for team in teams {
            if let player = team.players.first(where: { $0.id == id }) {
                return player
            }
        }
        return nil
    }

    func game(withId id: String) -> Game? {
        for week in 0..<schedule.count {
            if let game = game(withId: id, inWeek: week) {
                return game
            }
        }
        return nil
    }

    func game(withId id: String, inWeek week: Int) -> Game? {
        guard week < schedule.count else { return nil }
        return schedule[week].first(where: { $0.id == id })
    }
}
