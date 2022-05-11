//
//  GameHighlightsPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 3/1/22.
//

import UIKit

extension GameHighlightsViewController.Model.HighlightType {
    init(shotType: Shot.ShotType) {
        switch shotType {
        case .regular: self = .regular
        case .penalty: self = .penalty
        }
    }
}

extension GameHighlightsViewController.Model.HighlightResult {
    init(shotResult: Shot.ShotResult) {
        switch shotResult {
        case .goal: self = .goal
        case .miss: self = .miss
        case .save: self = .save
        }
    }
}

extension TeamHUDView.Model {

    init(team: Team, score: String, isAway: Bool) {
        var textColor = team.secondaryColor.uiColor
        if textColor == team.primaryColor.uiColor {
            textColor = .black
        }
        self.init(backgroundColor: team.primaryColor.uiColor,
                  textColor: textColor,
                  teamIcon: team.icon,
                  teamName: team.shortName,
                  score: score,
                  isLeftAligned: isAway)
    }
}

extension HighlightHUDView.Model {

    init(awayTeam: Team,
         awayScore: String,
         homeTeam: Team,
         homeScore: String,
         timeText: String) {
        let awayTeamModel = TeamHUDView.Model(team: awayTeam,
                                              score: awayScore,
                                              isAway: true)
        let homeTeamModel = TeamHUDView.Model(team: homeTeam,
                                              score: homeScore,
                                              isAway: false)

        self.init(awayTeamModel: awayTeamModel,
                  homeTeamModel: homeTeamModel,
                  timeText: timeText)
    }
}

extension HighlightPlayerView.Model {
    init(player: Player, team: Team, isOnOffense: Bool, isOnHomeTeam: Bool) {

        let zones = GameHighlightZones()
        let playerSize = zones.playerSize
        let name = player.firstInitialAndLastName
        var jerseyColor = isOnHomeTeam ? team.primaryColor.uiColor : team.secondaryColor.uiColor
        if player.position == .keeper {
            jerseyColor = isOnHomeTeam ? UIColor.keeperHomeColor : UIColor.keeperAwayColor
        }
        self.init(playerSize: playerSize,
                  name: name,
                  ratings: player.ratings,
                  jerseyColor: jerseyColor,
                  isFacingUp: isOnOffense)
    }
}

extension PlayerHighlightProfileView.Model {

    init(player: Player, team: Team, dataStore: DataStore) {
        var textColor = team.secondaryColor.uiColor
        if textColor == team.primaryColor.uiColor {
            textColor = .black
        }
        self.init(backgroundColor: team.primaryColor.uiColor,
                  textColor: textColor,
                  playerImage: dataStore.getPlayerImage(player, from: team),
                  playerName: "\(player.fullName) (\(player.position.shortName))",
                  teamImage: team.icon)
    }
}

extension GameHighlightsViewController.Model.HighlightModel {

    static func makeHighlight(awayTeam: Team,
                              awayScore: String,
                              homeTeam: Team,
                              homeScore: String,
                              shot: Shot,
                              dataStore: DataStore) -> Self {

        let hudModel = HighlightHUDView.Model(awayTeam: awayTeam,
                                              awayScore: awayScore,
                                              homeTeam: homeTeam,
                                              homeScore: homeScore,
                                              timeText: "\(shot.minute)'")

        let defendingTeam = shot.isForHomeTeam ? awayTeam : homeTeam
        let attackingTeam = shot.isForHomeTeam ? homeTeam : awayTeam

        let scorerProfileModel = PlayerHighlightProfileView.Model(
            player: shot.shooter,
            team: attackingTeam,
            dataStore: dataStore)

        let keeperModel = HighlightPlayerView.Model(player: shot.keeper,
                                                    team: defendingTeam,
                                                    isOnOffense: false,
                                                    isOnHomeTeam: !shot.isForHomeTeam)

        var allAttackers: [Player] = []
        let shooterModel = HighlightPlayerView.Model(player: shot.shooter,
                                                     team: attackingTeam,
                                                     isOnOffense: true,
                                                     isOnHomeTeam: shot.isForHomeTeam)
        allAttackers.append(shot.shooter)

        guard shot.type != .penalty else {
            // penalty kick
            return .init(type: .penalty,
                         result: .init(shotResult: shot.result),
                         hudModel: hudModel,
                         keeperModel: keeperModel,
                         shooterModel: shooterModel,
                         passerModel: nil,
                         otherAttackerModels: [],
                         defenderModels: [],
                         scorerProfileModel: scorerProfileModel)
        }

        var passerModel: HighlightPlayerView.Model? = nil
        if let passer = shot.passer {
            passerModel = HighlightPlayerView.Model(player: passer,
                                                    team: attackingTeam,
                                                    isOnOffense: true,
                                                    isOnHomeTeam: shot.isForHomeTeam)
            allAttackers.append(passer)
        }

        let maxNumOtherAttackers = passerModel == nil ? 3 : 2
        let numOtherAttackers = Int.random(in: 0...maxNumOtherAttackers)
        var otherAttackerModels: [HighlightPlayerView.Model] = []

        for _ in 0..<numOtherAttackers {
            guard let attacker = GameSimulator.selectGoalContributor(from: attackingTeam,
                                                                     excluding: allAttackers) else {
                continue
            }
            allAttackers.append(attacker)
            let attackerModel = HighlightPlayerView.Model(player: attacker,
                                                          team: attackingTeam,
                                                          isOnOffense: true,
                                                          isOnHomeTeam: shot.isForHomeTeam)
            otherAttackerModels.append(attackerModel)
        }

        let minNumDefenders = allAttackers.count - 1
        let numDefenders = Int.random(in: minNumDefenders...4)
        var defenderModels: [HighlightPlayerView.Model] = []
        var allDefenders: [Player] = []
        for _ in 0..<numDefenders {
            guard let defender = GameSimulator.selectGoalDefender(from: defendingTeam,
                                                                  excluding: allDefenders) else {
                continue
            }
            allDefenders.append(defender)
            let defenderModel = HighlightPlayerView.Model(player: defender,
                                                          team: defendingTeam,
                                                          isOnOffense: false,
                                                          isOnHomeTeam: !shot.isForHomeTeam)
            defenderModels.append(defenderModel)
        }

        return .init(type: .init(shotType: shot.type),
                     result: .init(shotResult: shot.result),
                     hudModel: hudModel,
                     keeperModel: keeperModel,
                     shooterModel: shooterModel,
                     passerModel: passerModel,
                     otherAttackerModels: otherAttackerModels,
                     defenderModels: defenderModels,
                     scorerProfileModel: scorerProfileModel)
    }
}

extension GameHighlightsViewController.Model {

    init(game: Game, league: League, dataStore: DataStore) {

        let away = league.team(withId: game.awayTeamId)
        let home = league.team(withId: game.homeTeamId)

        var awayScore = 0
        var homeScore = 0

//        let allGoals = game.awayGoals + game.homeGoals
//        let sortedGoals = allGoals.sorted(by: { $0.minute < $1.minute })
//        var highlightModels: [HighlightModel] = []
//        for goal in sortedGoals {
//            let highlightModel = HighlightModel.makeHighlight(awayTeam: away,
//                                                              awayScore: "\(awayScore)",
//                                                              homeTeam: home,
//                                                              homeScore: "\(homeScore)",
//                                                              goal: goal,
//                                                              dataStore: dataStore)
//            highlightModels.append(highlightModel)
//
//            if goal.isForHomeTeam {
//                homeScore += 1
//            } else {
//                awayScore += 1
//            }
//        }


        var highlightModels: [HighlightModel] = []
        for shot in game.shots {
            let highlightModel = HighlightModel.makeHighlight(awayTeam: away,
                                                              awayScore: "\(awayScore)",
                                                              homeTeam: home,
                                                              homeScore: "\(homeScore)",
                                                              shot: shot,
                                                              dataStore: dataStore)
            highlightModels.append(highlightModel)

            if shot.result == .goal {
                if shot.isForHomeTeam {
                    homeScore += 1
                } else {
                    awayScore += 1
                }
            }
        }


        let numFirstHalfHighlights = game.shots.filter({ $0.minute <= 45 }).count
        self.init(highlightModels: highlightModels,
                  numFirstHalfHighlights: numFirstHalfHighlights)
    }

}
