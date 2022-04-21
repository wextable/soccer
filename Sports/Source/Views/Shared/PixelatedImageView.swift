//
//  PixelatedImageView.swift
//  Sports
//
//  Created by Wesley St. John on 2/14/22.
//

import UIKit

class PixelatedImageView: UIImageView {

    override var image: UIImage? {
        didSet {
            layer.magnificationFilter = CALayerContentsFilter.nearest
            layer.shouldRasterize = true
        }
    }
}
