//
//  GlassProductList+Discount.swift
//  GlassUI
//
//  Created by Jordan Kay on 1/8/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import Foundation

extension GlassProductList {
    public struct DiscountInfoModel {
        var text: NSAttributedString?

        public init(text: NSAttributedString?) {
            self.text = text
        }
    }

    public static func makeDiscountLabel(model: DiscountInfoModel) -> GlassLabel {
        let label = GlassLabel(style: .captionRegular)
        label.attributedText = model.text
        return label
    }
}
