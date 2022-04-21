//
//  GlassProgressIndicator.swift
//  GlassUI
//
//  Created by Joshua Mann on 6/10/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public class GlassProgressIndicator: BaseView {
    internal let currentView: UIView = UIView(frame: .zero)

    public var percentComplete: CGFloat = 0.0 {
        didSet {
            self.indicatorTrailingConstraint?.constant = (100 - self.percentComplete) / 100 * self.frame.width
            self.accessibilityLabel = "\("progress".localize())"
            self.accessibilityValue = "\(Int(percentComplete))%"
            self.isAccessibilityElement = true
            self.accessibilityTraits = .summaryElement
        }
    }

    private var requiredWidth: CGFloat?
    private var fillStyle: FillStyle?

    internal var indicatorTrailingConstraint: NSLayoutConstraint!

    public init(width: CGFloat? = 200.0,
                fillStyle: FillStyle? = FillStyle.gray) {
        super.init(frame: .zero)
        self.fillStyle = fillStyle
        self.requiredWidth = width
        postInit()
    }

    func setConstraints() {
        self.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false

        indicatorTrailingConstraint = trailingAnchor.constraint(equalTo: currentView.trailingAnchor, constant: 0)
        var constraints = [
            heightAnchor.constraint(equalToConstant: 4.0),
            currentView.heightAnchor.constraint(equalToConstant: 6.0),
            indicatorTrailingConstraint,
            currentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            currentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            currentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]

        if let width = requiredWidth {
            constraints.append(widthAnchor.constraint(equalToConstant: width))
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(constraints)
    }

    func postInit() {
        currentView.backgroundColor = fillStyle?.fillColor.uiColor
        self.backgroundColor = GlassColor.gray20.uiColor
        currentView.roundCorners(corners: .allCorners, radius: 2)
        currentView.clipsToBounds = true
        self.roundCorners(corners: .allCorners, radius: 2)
        currentView.clipsToBounds = true
        setConstraints()

    }
}

extension GlassProgressIndicator {
    public enum FillStyle {
        case gray
        case blue

        var fillColor: GlassColor {
            switch self {
            case .gray:
                return GlassColor.gray80
            case .blue:
                return GlassColor.blue50
            }
        }
    }
}

#if DEBUG
extension GlassProgressIndicator {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: GlassProgressIndicator
        init(target: GlassProgressIndicator) {
            self.target = target
        }

        public var progressView: UIView {
            target.currentView
        }
    }
}
#endif
