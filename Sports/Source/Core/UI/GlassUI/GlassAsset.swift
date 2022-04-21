//
//  CoreAsset.swift
//  GlassUI
//
//  Created by John Liedtke on 6/26/19.
//  Copyright © 2019 Walmart. All rights reserved.
//

import UIKit

/// Collection of assets from the style sheet.
/// - For Accessibility in `CoreAsset`, set the `isAccessibilityElement` property of a `UIImageView` to `true` in
///    your code and set the `accessibilityLabel`.
/// - CoreAsset images are rendered as `alwaysOriginal`.
///
/// Example:
/// ```swift
/// imageView.image = CoreAsset.noPhotoWithoutTextPlaceholder.image
/// ```
public final class GlassAsset: NSObject {

    /// The underlying image rendered as `alwaysOriginal`.
    public private(set) lazy var image: UIImage? = {
        let image = UIImage.coreImage(named: assetName, bundle: nil)?.withRenderingMode(.alwaysOriginal)
        image?.accessibilityLabel = assetAccessibilityLabel

        return image
    }()

    public let name: String
    public let assetAccessibilityLabel: String

    private let assetName: String

    public init(assetName: String, name: String, accessibilityLabel: String) {
        self.assetName = assetName
        self.name = name
        self.assetAccessibilityLabel = accessibilityLabel

        super.init()
    }
}
