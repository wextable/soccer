//
//  Game.swift
//  Sports
//
//  Created by Wesley St. John on 12/23/21.
//

import Foundation

class Game: NSObject, Codable {

    enum State: Codable {
        case preGame
        case halftime
        case fullTime
    }

    let id: String
    let homeTeamId: String
    let awayTeamId: String
    let week: Int

    var homeScore: Int = 0
    var awayScore: Int = 0
    var shots: [Shot] = []
    var state: State = .preGame

    var homeGoals: [Shot] {
        return shots.filter { $0.result == .goal && $0.isForHomeTeam }
    }
    var awayGoals: [Shot] {
        return shots.filter { $0.result == .goal && !$0.isForHomeTeam }
    }

    init(id: String, homeTeamId: String, awayTeamId: String, week: Int) {
        self.id = id
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.week = week
        super.init()
    }
}

struct Goal: Equatable, Codable {
    let scorer: Player
    let assister: Player?
    let keeper: Player
    let minute: Int
    let isForHomeTeam: Bool
}

struct Shot: Equatable, Codable {
    enum ShotType: Codable {
        case regular
        case penalty
    }

    enum ShotResult: Codable {
        case goal
        case miss
        case save
    }

    let type: ShotType
    let result: ShotResult
    let shooter: Player
    let passer: Player?
    let keeper: Player
    let minute: Int
    let isForHomeTeam: Bool
}

extension Game {

    var desc: String {
        return ""
//        var description = "*** GAME RESULT ***\n"
//        description += "Home (\(homeTeam.name)): \(homeScore)\n"
//        for homeGoal in homeGoals {
//            description += "\(homeGoal.scorer.fullName),"
//            if let assister = homeGoal.assister {
//                description += " assisted by \(assister.fullName)"
//            }
//            description += " (\(homeGoal.minute))\n"
//        }
//        description += "Away (\(awayTeam.name)): \(awayScore)\n"
//        for awayGoal in awayGoals {
//            description += "\(awayGoal.scorer.fullName),"
//            if let assister = awayGoal.assister {
//                description += " assisted by \(assister.fullName)"
//            }
//            description += " (\(awayGoal.minute))\n"
//        }
//        return description
    }
}
