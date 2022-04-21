//
//  LeagueLeaderCell.swift
//  Sports
//
//  Created by Wesley St. John on 1/2/22.
//

import UIKit

class LeagueLeaderCell: BaseTableViewCell {

    let cellView: LeagueLeaderView = .init()

    var model: LeagueLeaderView.Model = .init() {
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
