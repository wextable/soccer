//
//  HighlightPlayerView.swift
//  Sports
//
//  Created by Wesley St. John on 2/28/22.
//

import UIKit

class HighlightPlayerView: BaseView {

    // MARK: Properties
    private let imageView = UIImageView()
    private let nameLabel = UILabel()

    var model: Model { didSet { applyModel() } }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        backgroundColor = .clear

        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        nameLabel.textColor = .white
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addSubview(imageView)
        addSubview(nameLabel)
    }
}

extension HighlightPlayerView {
    struct Model {
        var playerSize: CGSize = .init(width: 36, height: 18)
        var name: String = ""
        var ratings: Player.Ratings = .init(speed: 50,
                                            shooting: 50,
                                            passing: 50,
                                            dribbling: 50,
                                            defending: 50,
                                            goalkeeping: 50)
        var jerseyColor: UIColor = .white
        var isFacingUp: Bool = true
    }

    private func applyModel() {

        var imageViewY: CGFloat = 0
        var labelY: CGFloat = model.playerSize.height
        let labelWidth: CGFloat = 160
        let labelHeight: CGFloat = 20
        let labelX: CGFloat = -(labelWidth - model.playerSize.width) / 2.0
        if !model.isFacingUp {
            imageViewY = labelHeight
            labelY = 0
        }

        imageView.frame = CGRect(x: 0,
                                 y: imageViewY,
                                 width: model.playerSize.width,
                                 height: model.playerSize.height)
        let image = UIImage(named: "icon_player")
        imageView.image = image?.replacingColorAt(12, 16,
                                                  withColor: model.jerseyColor,
                                                  tolerance: 1)

        nameLabel.text = model.name
        nameLabel.frame = CGRect(x: labelX,
                                 y: labelY,
                                 width: labelWidth,
                                 height: labelHeight)
    }
}
