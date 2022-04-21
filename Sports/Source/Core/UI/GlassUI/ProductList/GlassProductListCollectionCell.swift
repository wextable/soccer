//
//  GlassProductListCollectionCell.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/1/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A collection cell with a product tile embedded in its content view.
open class GlassProductListCollectionCell: BaseCollectionViewCell {

    open var model: GlassProductList.Model {
        get { productList.model }
        set { productList.model = newValue }
    }

    public let productList: GlassProductList

    override init(frame: CGRect) {
        productList = GlassProductList()
        super.init(frame: frame)
    }

    open override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        contentView.addAutoLayoutSubview(productList)
    }

    open override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            productList.constraints(pinningTo: contentView)
        )
    }
}
