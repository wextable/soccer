//
//  GlassProductTile+ProductImageView.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

extension GlassProductList {

    // This class is a subview shown on the GlassProductTile. It displays the product image and add-to-cart button.
    class ProductImageView: BaseView {

        var model: ImageModel {
            didSet { applyModel() }
         }

        let imageView = UIImageView()
        private let stackView = UIStackView(axis: .vertical, alignment: .center)
        private var heightConstraint: NSLayoutConstraint?

        init(model: ImageModel = ImageModel()) {
            self.model = model

            imageView.contentMode = .scaleAspectFit

            super.init(frame: .zero)

            applyModel()
        }

        override func constructSubviewHierarchy() {
            super.constructSubviewHierarchy()

            stackView.addArrangedSubview(imageView)
            addAutoLayoutSubview(stackView)
        }

        override func constructSubviewLayoutConstraints() {
            super.constructSubviewLayoutConstraints()

            heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0).with(priority: .requiredCompliant)
            NSLayoutConstraint.activate(
                heightConstraint,
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                stackView.constraints(pinningTo: self)
            )
        }

        private func applyModel() {
            model.imageConfigurator?(imageView)
            stackView.alignment = model.alignment.containerAlignment
            imageView.alpha = model.imageOpacity
            heightConstraint?.constant = model.size.dimension
        }
    }
}
