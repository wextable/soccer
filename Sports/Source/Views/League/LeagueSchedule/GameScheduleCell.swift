//
//  GameScheduleCell.swift
//  Sports
//
//  Created by Wesley St. John on 2/24/22.
//

import UIKit

class GameScheduleCell: BaseTableViewCell {

    let cellView: GameScheduleView = .init()

    var model: GameScheduleView.Model = .init() {
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
