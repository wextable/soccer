//
//  TeamRosterPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

extension TeamRosterViewController.Model {

    init(team: Team) {
        self.init(playerModels: team.players.map { .init(player: $0) })
    }
}

extension PlayerListingView.Model {

    init(player: Player) {

        self.init(id: player.id,
                  position: "\(player.position.shortName)",
                  positionColor: player.position.color,
                  name: player.fullName,
                  overallRatingOutOfFive: player.ratings.overallStarRating,
                  overallPotentialOutOfFive: player.potential.overallStarRating,
                  offense: "\(player.ratings.overallScoring)",
                  defense: "\(player.ratings.overallDefensive)",
                  goals: "\(player.stats.goals)",
                  assists: "\(player.stats.assists)",
                  saves: "\(player.stats.saves)",
                  cleanSheets: "\(player.stats.cleanSheets)"
        )
    }
}
