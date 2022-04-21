//
//  GlassSwatch.swift
//  GlassUI
//
//  Created by Joshua Mann on 4/23/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A simple view for displaying for displaying up to four circular swatches.
public final class GlassSwatch: BaseView {
    public typealias SwatchConfiguration = (UIImageView) -> Void

    public struct Model {
        public static let maxSwatches = 4

        public enum Size {
            case regular, small
        }

        /// An array of closures for configuring a swatch image view. For instance, you may configure the image view
        /// to load a remote image or have a particular background color.
        public var swatchConfigurations: [SwatchConfiguration]

        /// The swatch count text, e.g. +4.
        public var countText: String

        /// Determines whether the count label is hidden.
        public var isCountLabelHidden: Bool

        /// The desired size of the swatch.
        public var size: Size

        /// The diameter of the circular swatch.
        public var diameter: CGFloat {
            switch size {
            case .regular: return 16.0
            case .small : return 8.0
            }
        }

        init(swatchConfigurations: [SwatchConfiguration], countText: String, isCountLabelHidden: Bool, size: Size) {
            self.swatchConfigurations = swatchConfigurations
            self.countText = countText
            self.isCountLabelHidden = isCountLabelHidden
            self.size = size
        }

        /// Creates and returns a swatch with the provided configuraiton and size.
        public init(swatchConfigurations: [SwatchConfiguration], size: Size) {
            self.init(
                swatchConfigurations: swatchConfigurations,
                countText: swatchConfigurations.count > Self.maxSwatches ?
                    "+\(swatchConfigurations.count - Self.maxSwatches)" : " ",
                isCountLabelHidden: false,
                size: size
            )
        }
    }

    public var model: Model? {
        didSet { applyModel() }
    }

    internal let countLabel: GlassLabel
    internal let swatchImageViews: [SwatchView]
    private let stackView: UIStackView

    public init(model: Model? = nil) {
        self.model = model
        swatchImageViews = (0..<Model.maxSwatches).map { _ in SwatchView() }
        countLabel = GlassLabel(style: .captionRegular)
        stackView = UIStackView(axis: .horizontal, alignment: .center)

        super.init(frame: .zero)

        applyModel()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews(swatchImageViews)
        stackView.addArrangedSubview(countLabel)
        addAutoLayoutSubview(stackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        stackView.spacing = GlassSpacing.xSmall
        NSLayoutConstraint.activate(stackView.constraints(pinningTo: self))
    }

    private func applyModel() {
        countLabel.text = model?.countText
        countLabel.isHidden = model?.isCountLabelHidden ?? true

        var swatchConfigurations = model?.swatchConfigurations ?? []
        swatchImageViews.forEach {
            $0.isHidden = swatchConfigurations.isEmpty
            $0.diameter = model?.diameter ?? 0

            let configuration: SwatchConfiguration? = swatchConfigurations.isEmpty
                ? nil
                : swatchConfigurations.removeFirst()
            configuration?($0)
        }
    }

    class SwatchView: UIImageView {

        init() {
            super.init(frame: .zero)
            contentMode = .scaleAspectFill
            layer.masksToBounds = true
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        var diameter: CGFloat = 8.0 {
            didSet {
                if diameter != oldValue {
                    invalidateIntrinsicContentSize()
                }
            }
        }

        override var intrinsicContentSize: CGSize {
            .init(diameter)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            layer.cornerRadius = bounds.size.height / 2.0
        }
    }
}
