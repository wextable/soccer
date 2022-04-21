//
//  PlayerCardCell.swift
//  Sports
//
//  Created by Wesley St. John on 4/19/22.
//

import UIKit

class PlayerCardCell: BaseCollectionViewCell {

    let cellView: PlayerCardView = .init()

    var model: PlayerCardView.Model = .init() {
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
