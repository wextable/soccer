//
//  ContainerView.swift
//  GlassUI
//
//  Created by John Liedtke on 5/11/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Combine
import UIKit

/// A simple tool for aligning a view in a container view.
/// - TOOD: JL Add docs + tests
class ContainerView: BaseView {

    enum Alignment {
        case leading, trailing, center
    }

    var embeddedView: UIView
    let axis: NSLayoutConstraint.Axis

    var alignment: Alignment {
        didSet { constructSubviewLayoutConstraints() }
    }

    private var store: Set<AnyCancellable> = []
    private var containerConstraints: [LayoutConstraining] = []

    init(_ embeddedView: UIView, axis: NSLayoutConstraint.Axis = .horizontal, alignment: Alignment) {
        self.embeddedView = embeddedView
        self.axis = axis
        self.alignment = alignment

        super.init(frame: .zero)

        embeddedView.publisher(for: \.isHidden).sink { [weak self] value in
            self?.isHidden = value
        }.store(in: &store)
    }

    override func constructView() {
        super.constructView()
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addAutoLayoutSubview(embeddedView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.deactivate(containerConstraints)

        switch axis {
        case .horizontal:
            switch alignment {
            case .center:
                containerConstraints = [
                    embeddedView.constraints(pinningTo: self, edges: .horizontal),
                    embeddedView.centerYAnchor.constraint(equalTo: centerYAnchor)
                ]

            case .leading:
                containerConstraints = [
                    embeddedView.constraints(pinningTo: self, edges: [.top, .horizontal]),
                    heightAnchor.constraint(greaterThanOrEqualTo: embeddedView.heightAnchor)
                ]

            case .trailing:
                containerConstraints = [
                    embeddedView.constraints(pinningTo: self, edges: [.bottom, .horizontal]),
                    heightAnchor.constraint(greaterThanOrEqualTo: embeddedView.heightAnchor)
                ]
            }

        case .vertical:
            switch alignment {
            case .center:
                containerConstraints = [
                    embeddedView.constraints(pinningTo: self, edges: .vertical),
                    embeddedView.centerXAnchor.constraint(equalTo: centerXAnchor)
                ]

            case .leading:
                containerConstraints = [
                     embeddedView.constraints(pinningTo: self, edges: [.leading, .vertical]),
                     widthAnchor.constraint(greaterThanOrEqualTo: embeddedView.widthAnchor)
                 ]

            case .trailing:
                containerConstraints = [
                    embeddedView.constraints(pinningTo: self, edges: [.vertical, .trailing]),
                    widthAnchor.constraint(greaterThanOrEqualTo: embeddedView.widthAnchor)
                ]
            }

        @unknown default:
            fatalError("Unknown `UIStackView.axis`: \(axis)")
        }

        NSLayoutConstraint.activate(containerConstraints)
    }
}
