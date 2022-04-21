//
//  TeamPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

extension TeamViewController.Model {

    init(team: Team, in league: League) {

        let isUserTeam = team.id == league.userTeamId
        let title = isUserTeam ? "My Team" : "\(team.longName) \(team.nickName)"

        var teamName = team.name
        if let teamRank = league.rankedTeams.firstIndex(where: { $0.id == team.id }) {
            teamName = "#\(teamRank + 1) \(teamName)"
        }
        let record = "\(teamName) (\(team.wins)-\(team.draws)-\(team.losses))"

        var opponentString: NSMutableAttributedString?
        if isUserTeam,
           league.currentWeek < team.schedule.count,
           let game = team.schedule[league.currentWeek] {
            var opponentWeek = "Week \(league.currentWeek + 1) vs. "
            let opponentId = (game.homeTeamId == league.userTeamId) ? game.awayTeamId : game.homeTeamId
            if let teamRank = league.rankedTeams.firstIndex(where: { $0.id == opponentId }) {
                opponentWeek += "#\(teamRank + 1) "
            }

            opponentString = NSMutableAttributedString(string: opponentWeek)
            let opponent = league.team(withId: opponentId)
            if let icon = opponent.icon {
                let imageAttachment = NSTextAttachment(image: icon)
                imageAttachment.bounds = CGRect(x: 0, y: -4, width: 17, height: 17)
                opponentString?.append(NSAttributedString(attachment: imageAttachment))
            }
            opponentString?.append(NSAttributedString(string: " \(opponent.name)"))
        }

        self.init(teamId: team.id,
                  title: title,
                  icon: team.icon,
                  record: record,
                  offensiveRatingOutOfFive: team.offensiveStarRating,
                  offensivePotentialOutOfFive: team.offensiveStarRating,
                  defensiveRatingOutOfFive: team.defensiveStarRating,
                  defensivePotentialOutOfFive: team.defensiveStarRating,
                  opponentString: opponentString,
                  isUserTeam: isUserTeam,
                  segments: [.teamRoster, .teamSchedule],
                  teamRosterModel: TeamRosterViewController.Model(team: team),
                  teamScheduleModel: TeamScheduleViewController.Model(team: team, in: league))
    }
}
