//
//  LeagueLeadersPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 1/2/22.
//

import Foundation

extension LeagueLeadersViewController.Model {

    init(league: League) {

        var playerModels: [LeagueLeaderView.Model] = []

        let sortedPlayers = league.allPlayers.sorted {
            if $0.stats.goals > $1.stats.goals {
                return true
            } else if $0.stats.goals < $1.stats.goals {
                return false
            } else if $0.stats.assists > $1.stats.assists {
                return true
            } else if $0.stats.assists < $1.stats.assists {
                return false
            } else if $0.overallRating > $1.overallRating {
                return true
            } else {
                return $0.overallRatingPotential > $1.overallRatingPotential
            }
        }
        
        for i in 0..<sortedPlayers.count {
            var team: Team?
            if let teamId = sortedPlayers[i].teamId {
                team = league.team(withId: teamId)
            }
            let model = LeagueLeaderView.Model(rankIndex: i, player: sortedPlayers[i], team: team)
            playerModels.append(model)
        }

        self.init(title: "\(league.name) Leaders",
                  playerModels: playerModels)
    }
}

extension LeagueLeaderView.Model {

    init(rankIndex: Int, player: Player, team: Team?) {

        self.init(id: player.id,
                  ranking: "\(rankIndex + 1)",
                  position: "\(player.position.shortName)",
                  positionColor: player.position.color,
                  name: player.fullName,
                  teamModel: .init(team: team),
                  goals: "\(player.stats.goals)",
                  assists: "\(player.stats.assists)",
                  saves: "\(player.stats.saves)",
                  cleanSheets: "\(player.stats.cleanSheets)",
                  overallRatingOutOfFive: player.overallStarRating,
                  overallPotentialOutOfFive: player.overallStarRatingPotential)
//                  overall: "\(player.ratings.overall)/\(player.potential.overall)")

    }
}

extension TeamIconNameView.Model {
    init(team: Team?) {
        self.init(icon: team?.icon, text: team?.name ?? "")
    }
}
