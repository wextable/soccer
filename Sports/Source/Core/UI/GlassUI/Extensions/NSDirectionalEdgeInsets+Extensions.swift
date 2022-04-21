//
//  NSDirectionalEdgeInsets+Extensions.swift
//  GlassUI
//
//  Created by Simon Bilsky-Rollins on 5/18/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public extension NSDirectionalEdgeInsets {
    /// Initializes the edge inset struct with a uniform inset across all edges.
    /// - Parameter inset: The uniform inset value.
    init(uniformInset inset: CGFloat) {
        self.init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
}
