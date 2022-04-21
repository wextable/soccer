//
//  UIView+Extensions.swift
//  Sports
//
//  Created by Wesley St. John on 3/1/22.
//

import UIKit

extension UIView {
    func paddedContainer(
        insets: LayoutConstrainingInsets = .init(top: .zero, leading: GlassSpacing.small,
                                                 bottom: .zero, trailing: GlassSpacing.small)
    ) -> UIView {
        let containerView = UIView()
        containerView.addAutoLayoutSubview(self)
        constraints(pinningTo: containerView,
                    edges: .all,
                    insets: insets).activate()
        return containerView
    }
}
