//
//  GlassRadioButton.swift
//  
//
//  Created by Rupani, Sohil (US - Seattle) on 1/29/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import UIKit

public protocol GlassRadioButtonDelegate: AnyObject {
    func didSelectButton(button: GlassRadioButton)
}

/// Base radio button control
/// https://zpl.io/25DL8M8
public class GlassRadioButton: UIButton {

    public enum BackgroundMode {
        case light
        case dark

        var defaultOuterColor: UIColor {
            switch self {
            case .light: return GlassColor.black.uiColor
            case .dark: return GlassColor.white.uiColor
            }
        }

        var disabledOuterColor: UIColor {
            return GlassColor.gray50.uiColor
        }

        var middleColor: UIColor {
            switch self {
            case .light: return GlassColor.white.uiColor
            case .dark: return .clear
            }
        }

        var innerColor: UIColor {
            switch self {
            case .light: return GlassColor.black.uiColor
            case .dark: return GlassColor.white.uiColor
            }
        }
    }

    private lazy var hapticEngine: GlassHapticEngine = {
        let engine = GlassHapticEngine()
        engine.view = self
        return engine
    }()

    public override var isEnabled: Bool {
        didSet {
            radioView.enabled = isEnabled
        }
    }

    public override var isSelected: Bool {
        didSet {
            accessibilityTraits = isSelected ? [.button, .selected] : [.button]
            radioView.isOn = isSelected
        }
    }

    public weak var delegate: GlassRadioButtonDelegate?

    private let expandedTapAreaInsets: UIEdgeInsets?
    private var radioView = RadioView()
    public var allowDeselection: Bool = true

    /// Creates an instance of `GlassRadioButton`
    ///
    /// - Parameters:
    ///   - frame: The frame to use for the button (defaults to `.zero`).
    ///   - expandedTapAreaInsets: UIEdgeInsets to use in expanding the tap area of the `GlassRadioButton`.
    public init(frame: CGRect = .zero,
                expandedTapAreaInsets: UIEdgeInsets? = nil,
                backgroundMode: BackgroundMode = .light) {
        self.expandedTapAreaInsets = expandedTapAreaInsets
        super.init(frame: frame)
        postInit(backgroundMode: backgroundMode)
    }

    override public init(frame: CGRect) {
        self.expandedTapAreaInsets = nil
        super.init(frame: frame)
        postInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.expandedTapAreaInsets = nil
        super.init(coder: aDecoder)
        postInit()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: RadioView.dimension, height: RadioView.dimension)
    }

    private func postInit(backgroundMode: BackgroundMode = .light) {
        self.translatesAutoresizingMaskIntoConstraints = false

        radioView.isUserInteractionEnabled = false
        radioView.backgroundMode = backgroundMode

        addAutoLayoutSubview(radioView)
        NSLayoutConstraint.activate([
            radioView.constraints(pinningTo: self, edges: .all),
            radioView.heightAnchor.constraint(equalToConstant: RadioView.dimension),
            radioView.widthAnchor.constraint(equalToConstant: RadioView.dimension)
        ])
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc internal func didTapButton() {
        if isSelected && !allowDeselection {
            return
        }

        isSelected = !isSelected
        hapticEngine.start(.medium)
        delegate?.didSelectButton(button: self)
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // GlassRadioButton does not support making the tap area smaller, as we should never do that.
        guard let expandedTapAreaInsets = expandedTapAreaInsets,
            expandedTapAreaInsets.left <= 0,
            expandedTapAreaInsets.right <= 0,
            expandedTapAreaInsets.top <= 0,
            expandedTapAreaInsets.bottom <= 0
        else {
            return super.point(inside: point, with: event)
        }

        return bounds.inset(by: expandedTapAreaInsets).contains(point)
    }

    // MARK: - RadioView
    private class RadioView: UIView {
        static let dimension = CGFloat(20)
        static let innerDimension = CGFloat(12)

        var backgroundMode: BackgroundMode = .light {
            didSet {
                update()
            }
        }

        var isOn: Bool = false {
            didSet {
                update()
            }
        }

        var enabled: Bool = true {
            didSet {
                update()
            }
        }

        override func layoutSubviews() {
            update()
        }

        internal func update() {
            guard bounds.size.width > 0 else { return }

            layer.cornerRadius = RadioView.dimension / 2.0
            layer.sublayers?.removeAll()

            let strokeWidth: CGFloat = 1.0
            let strokeColor = enabled ? backgroundMode.defaultOuterColor.cgColor
                                      : backgroundMode.disabledOuterColor.cgColor

            // The stroke is always drawn in the middle of the path.
            // So in order to fit it into the view exactly, we have to offset the radius
            // by half the stroke width.
            let outerRadius = (RadioView.dimension / 2.0) - (strokeWidth / 2.0)

            let outerPath = CGMutablePath()
            outerPath.addArc(center: center,
                             radius: outerRadius,
                             startAngle: 0.0,
                             endAngle: 2.0 * .pi,
                             clockwise: false)

            let outerLayer = CAShapeLayer()
            outerLayer.path = outerPath
            outerLayer.strokeColor = strokeColor
            outerLayer.lineWidth = strokeWidth
            outerLayer.fillColor = backgroundMode.middleColor.cgColor

            let innerPath = CGMutablePath()
            innerPath.addArc(center: center,
                             radius: RadioView.innerDimension / 2.0,
                             startAngle: 0.0,
                             endAngle: 2.0 * .pi,
                             clockwise: false)

            let innerLayer = CAShapeLayer()
            innerLayer.path = innerPath
            if enabled, isOn {
                innerLayer.fillColor = backgroundMode.innerColor.cgColor
            } else {
                innerLayer.fillColor = UIColor.clear.cgColor
            }

            layer.addSublayer(outerLayer)
            layer.addSublayer(innerLayer)
        }
    }

}
