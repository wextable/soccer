//
//  GlassProductCarouselFooterView.swift
//  GlassUI
//
//  Created by Lakshmikantha Hanumantharayappa on 6/21/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// The standard footer view in a product carousel.
///
public class GlassProductCarouselFooterView: BaseCollectionReusableView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeBottomBorder()
    }

    private func makeBottomBorder() {
        let border = GlassDivider()
        let borderHeight:CGFloat = 1.0
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderHeight, width: frame.size.width, height: borderHeight)
        addSubview(border)
    }
}
