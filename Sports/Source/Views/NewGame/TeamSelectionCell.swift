//
//  TeamSelectionCell.swift
//  Sports
//
//  Created by Wesley St. John on 4/3/22.
//

import UIKit

class TeamSelectionCell: BaseTableViewCell {

    let cellView: TeamSelectionView = .init()

    var model: TeamSelectionView.Model = .init() {
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
