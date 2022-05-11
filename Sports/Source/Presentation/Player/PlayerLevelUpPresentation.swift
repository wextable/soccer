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
        let prefix = ["has been working hard!",
                      "was practicing late at night all week long.",
                      "is really dedicated to his craft.",
                      "is a gym rat.",
                      "keeps getting better!",
                      "has been honing his skills.",
                      "doesn't fuck around.",
                      "is turning heads at practice.",
                      "just doesn't ever give up!",
                      "looks like he's been working out.",
                      "is always trying to improve.",
                      "is turning into a stud.",
                      "has caught our eye this week.",
                      "really wants to be a good player.",
                      "must have had sex this week.",
                      "totally got a blowjob in the parking lot.",
                      "started micro-dosing.",
                      "went on a zen meditation retreat.",
                      "FINALLY got those genital warts removed!",
                      "might have some real potential."].randomElement()!
        if let chosenSkill = chosenSkill {
            instructions = "\(player.fullName) \(prefix)\nHis \(chosenSkill.name) has really improved."
            instructions += "\nHe is now at level \(player.xpLevel)."
        }

        self.init(didLevelUp: chosenSkill != nil,
                  title: "\(player.fullName) (\(player.position.rawValue))",
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

