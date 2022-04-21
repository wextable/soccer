//
//  LayoutAnchorable.swift
//  GlassUI
//
//  Created by Alex Johnson on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// Describes a type that can be constrained by a UIKit layout.
///
/// You should not need to implement this protocol yourself; conformances for `UIView` and `UILayoutGuide` are provided.
public protocol LayoutAnchorable {
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var heightAnchor: NSLayoutDimension { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
}

extension UIView: LayoutAnchorable {}
extension UILayoutGuide: LayoutAnchorable {}
