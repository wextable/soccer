//
//  LeaguePresentation.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import Foundation

extension LeagueViewController.Model {

    init(league: League, week: Int) {
        let leagueStandingsModel = LeagueStandingsViewController.Model(league: league)
        let leagueScheduleModel = LeagueScheduleViewController.Model(league: league, week: week)
        let leagueLeadersModel = LeagueLeadersViewController.Model(league: league)

        self.init(title: league.name,
                  segments: [.leagueStandings,
                             .leagueSchedule,
                             .leagueLeaders],
                  leagueStandingsModel: leagueStandingsModel,
                  leagueScheduleModel: leagueScheduleModel,
                  leagueLeadersModel: leagueLeadersModel)
    }
}
