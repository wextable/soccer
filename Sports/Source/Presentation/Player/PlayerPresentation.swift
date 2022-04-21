//
//  PlayerPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 12/29/21.
//

import UIKit

extension PlayerViewController.Model {

    init(shouldShowCloseButton: Bool, player: Player, team: Team?, dataStore: DataStore) {

        var defensiveRatingOutOfFive = player.ratings.defensiveStarRating
        var defensivePotentialOutOfFive = player.potential.defensiveStarRating
        if player.position == .keeper {
            defensiveRatingOutOfFive = player.ratings.overallStarRating
            defensivePotentialOutOfFive = player.potential.overallStarRating
        }

        self.init(title: "\(player.fullName) (\(player.position.rawValue))",
                  shouldShowCloseButton: shouldShowCloseButton,
                  teamIcon: team?.icon,
                  teamName: team?.name ?? "",
                  offensiveRatingOutOfFive: player.ratings.offensiveStarRating,
                  offensivePotentialOutOfFive: player.potential.offensiveStarRating,
                  defensiveRatingOutOfFive: defensiveRatingOutOfFive,
                  defensivePotentialOutOfFive: defensivePotentialOutOfFive,
                  overallRatingOutOfFive: player.ratings.overallStarRating,
                  overallPotentialOutOfFive: player.potential.overallStarRating,
                  xp: player.xp,
                  potentialXP: player.potentialXP,
                  xpLevel: player.xpLevel,
//                  position: "Pos: \(player.position)",
//                  age: "Age: \(player.age)",
//                  height: "Height: \(feetToFeetInches(player.height))",
//                  weight: "Weight: \(player.weight) Lbs",
                  playerImage: dataStore.getPlayerImage(player, from: team),
//                  contract: "Contract: \(player.contract!.salary)m (\(player.contract!.duration)y)",
//                  speed: "Speed: \(player.ratings.speed)/\(player.potential.speed)",
//                  shooting: "Shooting: \(player.ratings.shooting)/\(player.potential.shooting)",
//                  passing: "Passing: \(player.ratings.passing)/\(player.potential.passing)",
//                  dribbling: "Dribbling: \(player.ratings.dribbling)/\(player.potential.dribbling)",
//                  defending: "Defending: \(player.ratings.defending)/\(player.potential.defending)",
//                  goalkeeping: "Goalkeeping: \(player.ratings.goalkeeping)/\(player.potential.goalkeeping)",
//                  overall: "Overall: \(player.ratings.overall)/\(player.potential.overall)",
//                  goals: "GOALS: \(player.stats.goals)",
//                  assists: "ASSISTS: \(player.stats.assists)",
//                  saves: "SAVES: \(player.stats.saves)",
//                  cleanSheets: "CLEAN SHEETS: \(player.stats.cleanSheets)",
                  segments: [.ratings],
                  ratingsModel: .init(player: player))
    }
}
