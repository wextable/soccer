//
//  GlassSegmentedControl.swift
//  GlassUI
//
//  Created by Tres Spicher on 1/27/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol GlassSegmentedControlSelectionDelegate {
    /// Delegate method to know what segment user has selected
    ///
    /// - Parameters:
    ///   - didSelectItemAt: value of selectedSegmentIndex of the segmentControl
    func segmentedControl(_ segmentedControl: GlassSegmentedControl, didSelectItemAt index: Int)
}

/**
 Is it a tab bar? Is it a segmented control? I don't know but it does mutually exclusive content switching!
 Naming is hard.

 Supports horizontal scrolling

 ```
 let segmentedControl: GlassSegmentedControl = GlassSegmentedControl()
 segmentedControl.segmentStyle = .imageOnTop
 let model = GlassSegmentedControl.Model(
     segments: [
         .init(image: UIImage(named: "grapeTomatoes"), title: "Fruits & Vegetables"),
         .init(image: UIImage(named: "basket"), title: "Frozen"),
         .init(image: UIImage(named: "dvd"), title: "Electronics"),
         .init(image: UIImage(named: "detergent"), title: "Home"),
         .init(image: UIImage(named: "chuckRoast"), title: "Meat")
     ],
     segmentStyle: .imageOnTop,
     showShadow: false
 )
 segmentedControl.model = model
 ```
 */
@objc
public final class GlassSegmentedControl: ScrollableSegmentedControl {

    private static let shadowSize: CGFloat = 4
    private static let shadowOpacity: Float = 0.4
    private static let shadowColor: GlassColor = GlassColor.gray200

    public weak var selectionDelegate: GlassSegmentedControlSelectionDelegate?

    public var model: Model = Model() {
        didSet {
            applyModel()
        }
    }

    public struct Model {
        public var backgroundColor: UIColor
        public var hasDynamicSegmentSize: Bool
        public var segments: [Segment]
        public var segmentStyle: ScrollableSegmentedControlSegmentStyle
        public var segmentTint: UIColor
        public var selectedSegmentIndex: Int
        public var shadowColor: UIColor
        public var showShadow: Bool

        public struct Segment {
            public var image: UIImage?
            public var imageUrl: URL?
            public var index: Int
            public var placeholderImage: UIImage?
            public var title: String?

            public init(
                image: UIImage? = nil,
                imageUrl: URL? = nil,
                index: Int = 0,
                placeholderImage: UIImage? = nil,
                title: String? = nil
            ) {
                self.image = image
                self.imageUrl = imageUrl
                self.index = index
                self.placeholderImage = placeholderImage
                self.title = title
            }
        }

        public init(
                    backgroundColor: UIColor = GlassColor.gray00.uiColor,
                    hasDynamicSegmentSize: Bool = true,
                    segments: [Segment] = [],
                    segmentStyle: ScrollableSegmentedControlSegmentStyle = .textOnly,
                    segmentTint: UIColor = GlassColor.blue100.uiColor,
                    selectedSegmentIndex: Int = 0,
                    shadowColor: UIColor = GlassColor.gray200.uiColor,
                    showShadow: Bool = false
                    ) {
            self.backgroundColor = backgroundColor
            self.hasDynamicSegmentSize = hasDynamicSegmentSize
            self.segments = segments
            self.segmentStyle = segmentStyle
            self.segmentTint = segmentTint
            self.selectedSegmentIndex = selectedSegmentIndex
            self.shadowColor = shadowColor
            self.showShadow = showShadow
        }
    }

    public init(frame: CGRect = .zero, model: Model = Model()) {
        super.init(frame: frame)
        applyModel()

        setTitleTextAttributes([.font: GlassFont.body2().uiFont], for: .normal)
        setTitleTextAttributes([.font: GlassFont.subheading2().uiFont], for: .selected)
        addTarget(self, action: #selector(selectedSegmentChanged), for: .valueChanged)
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override public func layoutSubviews() {
        super.layoutSubviews()

        underlineSelected = true
        segmentContentColor = GlassColor.gray200.uiColor
        selectedSegmentContentColor = GlassColor.gray200.uiColor
        setNormalTextAttributes()
    }

    @objc
    private func selectedSegmentChanged() {
        selectionDelegate?.segmentedControl(self, didSelectItemAt: selectedSegmentIndex)
    }

    private func applyModel() {
        self.removeAllSegments()
        self.backgroundColor = model.backgroundColor
        self.layer.shadowColor = model.shadowColor.cgColor
        self.segmentStyle = model.segmentStyle
        _ = model.segments.compactMap {
            self.insertSegment(
                withTitle: $0.title,
                image: $0.image,
                imageUrl: $0.imageUrl,
                placeholderImage: $0.placeholderImage,
                at: $0.index
            )
        }
        self.hasDynamicSegmentSize = model.hasDynamicSegmentSize
        self.selectedSegmentIndex = model.selectedSegmentIndex
        self.tintColor = model.segmentTint

        let shadowOpacity = model.showShadow ? GlassSegmentedControl.shadowOpacity: 0.0
        let shadowRadius = model.showShadow ? GlassSegmentedControl.shadowSize: 0.0

        applyDropShadowStyle(offset: CGSize(width: 0, height: GlassSegmentedControl.shadowSize),
                             opacity: shadowOpacity,
                             radius: shadowRadius,
                             color: GlassSegmentedControl.shadowColor)
        setNeedsLayout()
    }
}
