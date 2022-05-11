//
//  TeamRosterPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

extension TeamRosterViewController.Model {

    init(team: Team, isUserTeam: Bool) {
        self.init(playerModels: team.players.map {
            .init(player: $0, on: team, isUserTeam: isUserTeam)
        })
    }
}

extension PlayerListingView.Model {

    init(player: Player, on team: Team, isUserTeam: Bool) {

        var isCheckboxEnabled = isUserTeam && !player.isInjured
        if !player.isStarting {
            
            if player.position == .keeper {
                if team.starters.contains(where: { $0.position == .keeper }) {
                    isCheckboxEnabled = false
                }
            } else {
                let numStartingNonKeepers = team.starters.filter(
                    { $0.position != .keeper }
                ).count
                if numStartingNonKeepers >= GameConfig.config.teamMakeup.numStartersPerTeam - 1 {
                    isCheckboxEnabled = false
                }
            }
        }

        var statusIcon: UIImage?
        if player.isInjured {
            statusIcon = UIImage(named: "icon_status_injury")
        }

        let conditionColor: UIColor
        switch player.condition {
        case 0...25: conditionColor = .red
        case 25..<70: conditionColor = UIColor.rgb(r: 237, g: 153, b: 38)
        default: conditionColor = UIColor.rgb(r: 28, g: 187, b: 46)
        }

        self.init(id: player.id,
                  isCheckboxHidden: false,
                  isCheckboxEnabled: isCheckboxEnabled,
                  isCheckboxSelected: player.isStarting,
                  position: "\(player.position.shortName)",
                  positionColor: player.position.color,
                  name: player.fullName,
                  statusIcon: statusIcon,
                  condition: "\(player.condition)%",
                  conditionColor: conditionColor,
                  overallRatingOutOfFive: player.overallStarRating,
                  overallPotentialOutOfFive: player.overallStarRatingPotential,
                  offense: "\(player.overallScoring)",
                  defense: "\(player.overallDefensive)",
                  goals: "\(player.stats.goals)",
                  assists: "\(player.stats.assists)",
                  saves: "\(player.stats.saves)",
                  cleanSheets: "\(player.stats.cleanSheets)"
        )
    }
}
