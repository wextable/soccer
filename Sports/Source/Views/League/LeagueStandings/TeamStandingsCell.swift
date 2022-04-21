//
//  TeamStandingsCell.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

class TeamStandingsCell: BaseTableViewCell {

    let cellView: TeamStandingsView = .init()

    var model: TeamStandingsView.Model = .init() {
        didSet {
            applyModel()
        }
    }

    private func applyModel() {
        cellView.model = model
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        selectionStyle = .none

        applyModel()
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        contentView.addAutoLayoutSubview(cellView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        cellView.constraints(pinningTo: contentView).activate()
    }
    
}

