//
//  TeamSelectionPresentation.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import UIKit

extension TeamSelectionViewController.Model {

    init(teams: [Team]) {
        self.init(title: "Choose a team",
                  teamModels: teams.map { .init(team: $0) })
    }
}

extension TeamSelectionView.Model {

    init(team: Team) {
        self.init(id: team.id,
                  image: team.icon,
                  name: team.longName + " " + team.nickName,
                  prestige: team.prestige)

    }
}
