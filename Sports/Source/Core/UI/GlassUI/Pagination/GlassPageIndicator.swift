//
//  PageIndicator.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/27/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public class GlassPageIndicator: ElevatingView {
    public var pageCount: Int = 0
    public var selectedIndex: Int = 0 {
        didSet {
            if (0..<pageCount).contains(selectedIndex) {
                update(newIndex: selectedIndex, oldIndex: oldValue)
            } else {
                selectedIndex = oldValue
            }
        }
    }

    internal var selectedColor: GlassColor = GlassColor.gray200
    internal var indicatorColor: GlassColor = GlassColor.gray50

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = GlassSpacing.xSmall

        return stackView
    }()

    public init(_ pageCount: Int) {
        super.init(elevationLevel: .two)
        self.pageCount = pageCount
        postInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(newIndex: Int, oldIndex: Int) {
        let newView = stackView.arrangedSubviews[newIndex]
        let oldView = stackView.arrangedSubviews[oldIndex]

        UIView.animate(withDuration: GlassAnimation.animationTimeMedium) { [weak self] in
            guard let self = self else { return }
            oldView.backgroundColor = self.indicatorColor.uiColor
            newView.backgroundColor = self.selectedColor.uiColor
        }
    }

    func setConstraints() {
        self.addSubview(stackView)
        var constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.xxSmall),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassSpacing.xxSmall),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlassSpacing.xSmall),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlassSpacing.xSmall)
        ]

        for view in stackView.subviews {
            constraints.append(view.widthAnchor.constraint(equalToConstant: GlassSpacing.xSmall))
            constraints.append(view.heightAnchor.constraint(equalToConstant: GlassSpacing.xSmall))
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(constraints)
    }

    func postInit() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        self.backgroundColor = GlassColor.gray00.uiColor
        self.layer.cornerRadius = GlassSpacing.small / 2
        for index in 0..<pageCount {
            let view = UIView()
            view.layer.cornerRadius = GlassSpacing.xSmall / 2
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = indicatorColor.uiColor
            if index == selectedIndex {
                view.backgroundColor = selectedColor.uiColor
            }
            view.setNeedsLayout()
            view.layoutIfNeeded()
            stackView.addArrangedSubview(view)
        }

        setConstraints()
    }
}
