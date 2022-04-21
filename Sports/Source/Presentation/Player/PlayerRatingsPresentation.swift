//
//  PlayerRatingsPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import Foundation

extension PlayerRatingsViewController.Model {

    init(player: Player) {

        self.init(title: player.fullName + " " + player.position.shortName,
                  ratingModels: [
                    .init(ratingType: .speed,
                          rating: player.ratings.speed,
                          potentialRating: player.potential.speed),
                    .init(ratingType: .shooting,
                          rating: player.ratings.shooting,
                          potentialRating: player.potential.shooting),
                    .init(ratingType: .passing,
                          rating: player.ratings.passing,
                          potentialRating: player.potential.passing),
                    .init(ratingType: .dribbling,
                          rating: player.ratings.dribbling,
                          potentialRating: player.potential.dribbling),
                    .init(ratingType: .defending,
                          rating: player.ratings.defending,
                          potentialRating: player.potential.defending),
                    .init(ratingType: .goalkeeping,
                          rating: player.ratings.goalkeeping,
                          potentialRating: player.potential.goalkeeping)
                  ]
        )
    }
}
