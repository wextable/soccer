//
//  TeamIconNameView.swift
//  Sports
//
//  Created by Wesley St. John on 4/13/22.
//

import UIKit
import SwiftUI

class TeamIconNameView: BaseView {

    // MARK: Properties

    private let imageView = UIImageView()
    private let label = GlassLabel(style: .body2)

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubviews([
            imageView,
            label
        ])
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        let size: CGFloat = 17.0

        NSLayoutConstraint.activate(
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                           constant: GlassSpacing.xSmall),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        )
    }
}

extension TeamIconNameView {
    struct Model: Hashable {
        var icon: UIImage?
        var text: String = ""
    }

    private func applyModel() {
        imageView.image = model.icon
        label.text = model.text
    }
}
