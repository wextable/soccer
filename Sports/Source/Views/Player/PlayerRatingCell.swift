//
//  PlayerRatingCell.swift
//  Sports
//
//  Created by Wesley St. John on 4/4/22.
//

import UIKit

class PlayerRatingCell: BaseTableViewCell {

    let cellView: PlayerRatingView = .init()

    var model: PlayerRatingView.Model = .init() {
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
        contentView.backgroundColor = .white

        applyModel()
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        contentView.addAutoLayoutSubview(cellView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        NSLayoutConstraint.activate(
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: GlassSpacing.xxSmall),
            cellView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        )
    }

}
