//
//  PlayerListingCell.swift
//  Sports
//
//  Created by Wesley St. John on 12/28/21.
//

import UIKit

protocol PlayerListingCellDelegate: AnyObject {
    func checkboxToggled(isSelected: Bool, sender: PlayerListingCell)
}

class PlayerListingCell: BaseTableViewCell {

    weak var delegate: PlayerListingCellDelegate?
    
    let cellView: PlayerListingView = .init()

    var model: PlayerListingView.Model = .init() {
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
        cellView.delegate = self
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

extension PlayerListingCell: PlayerListingViewDelegate {
    func checkboxToggled(isSelected: Bool, sender: PlayerListingView) {
        delegate?.checkboxToggled(isSelected: isSelected, sender: self)
    }
}
