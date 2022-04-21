//
//  BarRatingView.swift
//  Sports
//
//  Created by Wesley St. John on 4/6/22.
//

import UIKit

class BarRatingView: BaseView {

    // MARK: Properties

    private let backgroundView = BaseView()
    private let foregroundView = BaseView()
    private var backgroundWidthConstraint = NSLayoutConstraint()
    private var foregroundWidthConstraint = NSLayoutConstraint()

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

        clipsToBounds = true
        layer.cornerRadius = 4.0
        backgroundView.clipsToBounds = true
        backgroundView.layer.borderWidth = 2.0
        backgroundView.layer.cornerRadius = 3.0
        foregroundView.clipsToBounds = true
        foregroundView.layer.cornerRadius = 3.0
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(backgroundView)
        addAutoLayoutSubview(foregroundView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        backgroundWidthConstraint = backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor)
        foregroundWidthConstraint = foregroundView.widthAnchor.constraint(equalTo: self.widthAnchor)

        let padding: CGFloat = 2.0
        NSLayoutConstraint.activate(
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            backgroundWidthConstraint,
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            foregroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            foregroundWidthConstraint,
            foregroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            foregroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
//            heightAnchor.constraint(equalToConstant: 24.0)
        )
    }
}

extension BarRatingView {
    struct Model {
        var ratingPercent: Double = 1
        var potentialRatingPercent: Double = 1
        var backgroundColor: UIColor = .black
        var potentialColor: UIColor = .lightGray
        var ratingColor: UIColor = UIColor.rgb(r: 253, g: 193, b: 56)
    }

    private func applyModel() {

        backgroundWidthConstraint.deactivate()
        foregroundWidthConstraint.deactivate()
        backgroundView.removeConstraint(backgroundWidthConstraint)
        foregroundView.removeConstraint(foregroundWidthConstraint)

        backgroundWidthConstraint = backgroundView.widthAnchor.constraint(
            equalTo: self.widthAnchor,
            multiplier: CGFloat(model.potentialRatingPercent)
        )
        foregroundWidthConstraint = foregroundView.widthAnchor.constraint(
            equalTo: self.widthAnchor,
            multiplier: CGFloat(model.ratingPercent)
        )

        NSLayoutConstraint.activate(
            backgroundWidthConstraint,
            foregroundWidthConstraint
        )

        backgroundColor = model.backgroundColor
        backgroundView.backgroundColor =  .clear //model.potentialColor
        backgroundView.layer.borderColor = model.ratingColor.cgColor
        foregroundView.backgroundColor = model.ratingColor
    }
}
