//
//  PlayerLevelUpPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 4/27/22.
//

import UIKit

extension PlayerLevelUpViewController.Model {

    init(player: Player,
         team: Team?,
         dataStore: DataStore,
         chosenSkill: Player.Rating? = nil) {

        var defensiveRatingOutOfFive = player.defensiveStarRating
        var defensivePotentialOutOfFive = player.defensiveStarRatingPotential
        if player.position == .keeper {
            defensiveRatingOutOfFive = player.overallStarRating
            defensivePotentialOutOfFive = player.overallStarRatingPotential
        }

        var instructions = "\(player.fullName) has leveled up!\nChoose a skill to improve!"
        if let chosenSkill = chosenSkill {
            instructions = "\(player.fullName) has been working hard!\nHis \(chosenSkill.name) has really improved."
            instructions += "\nHe is now at level \(player.xpLevel)."
        }

        self.init(title: "\(player.fullName) (\(player.position.rawValue))",
                  shouldShowCloseButton: true,
                  teamIcon: team?.icon,
                  teamName: team?.name ?? "",
                  offensiveRatingOutOfFive: player.offensiveStarRating,
                  offensivePotentialOutOfFive: player.offensiveStarRatingPotential,
                  defensiveRatingOutOfFive: defensiveRatingOutOfFive,
                  defensivePotentialOutOfFive: defensivePotentialOutOfFive,
                  overallRatingOutOfFive: player.overallStarRating,
                  overallPotentialOutOfFive: player.overallStarRatingPotential,
                  xp: player.xp,
                  potentialXP: player.potentialXP,
                  xpLevel: player.xpLevel,
                  playerImage: dataStore.getPlayerImage(player, from: team),
                  instructions: instructions,
                  ratingsModel: .init(player: player))
    }
}

