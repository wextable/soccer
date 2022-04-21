//
//  GlassButtons.swift
//  GlassUI
//
//  Created by Cihan Cimen on 4/26/17.
//  Copyright © 2018 WalmartLabs. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
/// Superclass for Primary, Seconday, Icon, and Banner buttons
///
/// Do not use this superclass directly.
///
/// [Zeplin Reference](https://zpl.io/VYEAq5M)

open class GlassButton: UIButton, Accessible {

    public var buttonStyle: GlassButtonStyle = .large {
        didSet {
            applyStyle()
        }
    }

    static internal let defaultHighlightedAlphaTitleColor: CGFloat = 0.5

    /// Set this color to provide custom text color for colored buttons
    /// Set customDisabledForegroundColor along with customEnabledForegroundColor
    open var customEnabledForegroundColor: GlassColor? {
        didSet {
            self.applyStyle()
        }
    }

    /// Set this color to provide custom text color for colored disabled buttons
    /// Set customEnabledForegroundColor along with customDisabledForegroundColor
    open var customDisabledForegroundColor: GlassColor? {
        didSet {
            self.applyStyle()
        }
    }

    /// Set this color to provide custom background color for enabled buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    open var customEnabledBackgroundColor: GlassColor? {
        didSet {
            self.applyStyle()
        }
    }

    /// Set this color to provide custom background color for highlighted buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    open var customHighlightedBackgroundColor: GlassColor? {
        didSet {
            self.applyStyle()
        }
    }

    /// Set this color to provide custom background color for disabled buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    open var customDisabledBackgroundColor: GlassColor? {
        didSet {
            self.applyStyle()
        }
    }

    /// Use this to opt out of formatting when setting this button's title.
    /// Perhaps you have a button which has a proper noun as its title. This might be a good place to set
    /// `button.titleHasCustomFormatting = true`
    open var titleHasCustomFormatting = false

    /// A block which will be invoked after taps (`touchUpInside`)
    ///
    /// As always with blocks be careful not to create retention cycles.
    public var onTap: GlassButtonTapHandler?

    /// Default init override
    override public init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    public init(buttonStyle: GlassButtonStyle = .large) {
        self.buttonStyle = buttonStyle
        super.init(frame: .zero)
        postInit()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    func postInit() {
        applyStyle()
        registerTapHandler()
    }

    open func applyStyle() {
        clipsToBounds = true

        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.baselineAdjustment = .alignCenters

        contentEdgeInsets.left = buttonStyle.contentInset
        contentEdgeInsets.right = buttonStyle.contentInset
    }

    open override var intrinsicContentSize: CGSize {
        return buttonStyle.buttonSize
    }

    open override func setTitle(_ title: String?, for state: UIControl.State) {
        let formattedTitle = format(title)
        super.setTitle(formattedTitle, for: state)
        self.accessibilityLabel = title
    }

    open override var isEnabled: Bool {
        didSet {
            if isEnabled {
                accessibilityTraits = [.button]
            } else {
                accessibilityTraits = [.button, .notEnabled]
            }
        }
    }

    /// Formatting to be applied when calling `setTitle(_:for:)`
    /// You can opt out of formatting by using the `titleHasCustomFormatting` flag
    private func format(_ title: String?) -> String? {
        if !titleHasCustomFormatting {
            return title?.toSentenceCase()
        } else {
            return title
        }
    }
}

/// Full width buttons for long button labels, with blue #0071dc background, white text color and rounded corners.
open class GlassPrimaryButton: GlassButton {

    enum GlassPrimaryButtonIconPosition {
        case leading, trailing
        static let padding = GlassSpacing.small
    }

    /// Holds the current `GlassActivityIndicator` (if started).
    private let activityIndicator: GlassActivityIndicator = {
        let activityIndicator = GlassActivityIndicator(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.fillColor = GlassColor.gray00.uiColor
        activityIndicator.stopAnimating()
        activityIndicator.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        activityIndicator.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return activityIndicator
    }()

    /// Holds the button's titles while it is animating
    private var titles: Titles?

    /// Returns whether the button is currently animating or not.
    public var isAnimating: Bool {
        activityIndicator.isAnimating
    }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: intrinsicWidth,
                      height: buttonStyle.buttonSize.height)
    }

    private var intrinsicWidth: CGFloat {
        let size = (titleLabel?.intrinsicContentSize.width ?? GlassButtonStyle.large.buttonSize.width) +
            (2 * buttonStyle.contentInset) + updateIntrinsicSizeForIcon()
        return size
    }

    public var leadingIcon: GlassIcon? {
        didSet {
            setIcon(icon: leadingIcon, position: .leading)
        }
    }

    public var trailingIcon: GlassIcon? {
        didSet {
            setIcon(icon: trailingIcon, position: .trailing)
        }
    }

    private func setIcon(icon: GlassIcon?, position: GlassPrimaryButtonIconPosition) {
        let image = icon?.imageSize16()?.withRenderingMode(.alwaysTemplate)
        setImage(image,
                 for: .normal)
        imageView?.contentMode = .scaleAspectFit
        imageView?.tintColor = GlassColor.gray00.uiColor
        switch position {
        case .leading:
            semanticContentAttribute = .forceLeftToRight
            imageEdgeInsets = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: GlassPrimaryButtonIconPosition.padding)
        case .trailing:
            semanticContentAttribute = .forceRightToLeft
            imageEdgeInsets = UIEdgeInsets(top: 0,
                                           left: GlassPrimaryButtonIconPosition.padding,
                                           bottom: 0,
                                           right: 0)
        }
    }

    open override func applyStyle() {
        super.applyStyle()

        setTitleColor((customEnabledForegroundColor ?? GlassColor.gray00).uiColor,
                      for: .normal)
        setTitleColor((customEnabledForegroundColor ?? GlassColor.gray00).uiColor,
        for: .highlighted)
        setTitleColor((customDisabledForegroundColor ?? GlassColor.gray00).uiColor,
                      for: .disabled)

        setBackgroundColor((customEnabledBackgroundColor ?? GlassColor.blue100).uiColor,
                           for: .normal)
        setBackgroundColor((customHighlightedBackgroundColor ?? GlassColor.blue160).uiColor,
                           for: .highlighted)
        setBackgroundColor((customDisabledBackgroundColor ?? GlassColor.gray50).uiColor,
                           for: .disabled)

        activityIndicator.fillColor = (customEnabledForegroundColor ?? GlassColor.gray00).uiColor

        switch buttonStyle {
        case .large:
            titleLabel?.font = GlassFont.subheading1().uiFont
        case .small:
            titleLabel?.font = GlassFont.subheading2().uiFont
        }

        layer.cornerRadius = buttonStyle.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.textAlignment = .center

        setContentHuggingPriority(.required, for: .vertical)
        addAutoLayoutSubview(activityIndicator)

        NSLayoutConstraint.activate(
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
            activityIndicator.widthAnchor.constraint(equalTo: activityIndicator.heightAnchor)
        )
    }

    /// Adds an animating `GlassActivityIndicator` to the center of the button.
    /// To stop the animation, call `stopAnimating()`.
    /// > Note: While the button is animating, it cannot be clicked.
    open func startAnimating() {

        guard !isAnimating else { return }

        captureButtonTitles()
        clearAllButtonTitles()
        setImage(nil, for: .normal)
        self.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }

    /// Stops the `GlassActivityIndicator` started in `startAnimating()`.
    /// Calling this will also make the button clickable again.
    open func stopAnimating() {
        guard isAnimating else { return } // Skip if already animating

        restoreButtonTitles()
        setImage((leadingIcon ?? trailingIcon)?.imageSize16()?.withRenderingMode(.alwaysTemplate),
                 for: .normal)

        self.titles = nil
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }

    private func updateIntrinsicSizeForIcon() -> CGFloat {
        if leadingIcon != nil || trailingIcon != nil {
            return GlassSpacing.small + GlassPrimaryButtonIconPosition.padding
        }
        return 0
    }

    private func captureButtonTitles() {
        var titles = Titles()
        titles.normal = title(for: .normal)
        titles.highlighted = title(for: .highlighted)
        titles.disabled = title(for: .disabled)
        titles.selected = title(for: .selected)
        self.titles = titles
    }

    private func clearAllButtonTitles() {
        setTitle(nil, for: .normal)
        setTitle(nil, for: .highlighted)
        setTitle(nil, for: .disabled)
        setTitle(nil, for: .selected)
    }

    private func restoreButtonTitles() {
        setTitle(titles?.normal, for: .normal)
        setTitle(titles?.highlighted, for: .highlighted)
        setTitle(titles?.disabled, for: .disabled)
        setTitle(titles?.selected, for: .selected)
    }

    private struct Titles {
        var normal: String?
        var disabled: String?
        var highlighted: String?
        var selected: String?
    }

}

/// Buttons with Icon in the center with blue background and white text
/// ```swift
///    let iconButton: GlassIconButton = GlassIconButton(icon: GlassIcon.removeClose)
///    iconButton.translatesAutoresizingMaskIntoConstraints = false
/// ```
open class GlassIconButton: GlassButton {
    public var buttonIcon: GlassIcon? {
        didSet {
            iconView.image = buttonIcon?.imageSize16()?.withRenderingMode(.alwaysTemplate)
            if let iconAccessibilityLabel = buttonIcon?.iconAccessibilityLabel,
                !iconAccessibilityLabel.isEmpty {
                accessibilityLabel = iconAccessibilityLabel
            }
        }
    }
    private let iconView = UIImageView()

    public var iconViewDimension: CGFloat = GlassButtonStyle.small.buttonSize.height {
        didSet {
            setupConstraints()
        }
    }

    public var iconDimension: CGFloat {
        return iconViewDimension / 2.0
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: iconViewDimension, height: iconViewDimension)
    }

    public init(icon: GlassIcon? = nil) {
        super.init(buttonStyle: .large)
        buttonIcon = icon
        if let iconAccessibilityLabel = buttonIcon?.iconAccessibilityLabel,
            !iconAccessibilityLabel.isEmpty {
            accessibilityLabel = iconAccessibilityLabel
        }
        iconView.image = buttonIcon?.imageSize16()?.withRenderingMode(.alwaysTemplate)
        postInit()
    }

    override func postInit() {
        super.postInit()

        // Add Icon View and update Title label insets
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    }

    func setupConstraints() {
        removeConstraints(constraints)
        iconView.removeConstraints(iconView.constraints)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: iconViewDimension),
            heightAnchor.constraint(equalToConstant: iconViewDimension),
            iconView.widthAnchor.constraint(equalToConstant: iconDimension),
            iconView.heightAnchor.constraint(equalToConstant: iconDimension),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        applyStyle()
    }

    open override func applyStyle() {
        super.applyStyle()

        titleLabel?.font = GlassFont.body2().uiFont
        iconView.tintColor = (customEnabledForegroundColor ?? GlassColor.gray00).uiColor
        setBackgroundColor((customEnabledBackgroundColor ?? GlassColor.blue100).uiColor,
                           for: .normal)
        setBackgroundColor((customHighlightedBackgroundColor ?? GlassColor.blue160).uiColor,
                           for: .highlighted)
        setBackgroundColor((customDisabledBackgroundColor ?? GlassColor.gray50).uiColor,
                           for: .disabled)
        layer.cornerRadius = iconViewDimension / 2.0
        clipsToBounds = true
    }
}

// MARK: - Button background image helpers
public extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

public extension UIButton {
    func backgroundColorImage(for color: UIColor) -> UIImage {
        let image: UIImage = UIImage.from(color: color)
        let stretchableImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        return stretchableImage
    }

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let backgroundColor = color {
            setBackgroundImage(backgroundColorImage(for: backgroundColor), for: state)
        } else {
            setBackgroundImage(nil, for: state)
        }
    }
}

extension String {
    func toSentenceCase() -> String {
        var modifiedString = prefix(1).uppercased() + self.lowercased().dropFirst()
        do {
            // Capitalize for the personal pronoun "I" and sentences
            let personalPronounRegex =
                try NSRegularExpression(pattern: #"\Wi\W|(?<=(\—)(i|I)\s)|(?<=(\.|\!|\?))\s[a-z]"#)
            let results = personalPronounRegex.matches(
                in: modifiedString,
                range: NSRange(modifiedString.startIndex..., in: modifiedString)).map {
                    String(modifiedString[Range($0.range, in: modifiedString)!])
            }
            let modifiedResults = results.map { $0.uppercased() }
            for (original, capitalized) in zip(results, modifiedResults) {
                modifiedString = modifiedString.replacingOccurrences(of: original, with: capitalized)
            }
        } catch {
        }
        return modifiedString
    }

    mutating func capitalizeFirstLetter() {
        self = self.toSentenceCase()
    }
}

/// Full width buttons for long button labels, with blue #0071dc background, white text color and rounded corners.
// This component will be removed, it is not considered a core component
open class GlassBannerButton: GlassButton {

    static var bannerCornerRadius: CGFloat = 4

    private var primaryLabel: GlassLabel = GlassLabel()
    private var subheaderLabel: GlassLabel = GlassLabel()
    private var iconView: UIImageView = UIImageView()
    public var icon: GlassIcon! {
        didSet {
            iconView.image = icon.image.withRenderingMode(.alwaysTemplate)
        }
    }

    open override var intrinsicContentSize: CGSize {
        let width: CGFloat = iconView.intrinsicContentSize.width + primaryLabel.intrinsicContentSize.width +
            buttonStyle.contentInset * 2
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }

    public init(icon: GlassIcon) {
        super.init(buttonStyle: .large)
        self.icon = icon
        iconView.image = icon.image.withRenderingMode(.alwaysTemplate)
        subheaderLabel.numberOfLines = 0
        postInit()
    }

    override func postInit() {
        super.postInit()

        addAutoLayoutSubview(iconView)
        addAutoLayoutSubview(primaryLabel)
        addAutoLayoutSubview(subheaderLabel)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall),
            iconView.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall),
            // swiftlint:disable todo
            // TODO: Zeplin designs say 18, GlassSpacing specifies 16 or 24
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlassSpacing.small),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: primaryLabel.leadingAnchor, constant: -GlassSpacing.small),
            primaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.small),
            primaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlassSpacing.small),
            subheaderLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 0),
            subheaderLabel.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor, constant: 0),
            subheaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlassSpacing.small),
            subheaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassSpacing.small)
        ])

        self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    override open func setTitle(_ title: String?, for state: UIControl.State) {
        primaryLabel.text = title
        setAccessibility()
    }

    override open func title(for state: UIControl.State) -> String? {
        return primaryLabel.text
    }

    public func setSubheaderTitle(_ title: String?, for state: UIControl.State) {
        subheaderLabel.text = title
        setAccessibility()
    }

    public func subheaderTitle(for state: UIControl.State) -> String? {
        return subheaderLabel.text
    }

    open override func applyStyle() {
        super.applyStyle()
        primaryLabel.font = GlassFont.pageTitle().uiFont
        primaryLabel.textColor = (customEnabledForegroundColor ?? GlassColor.gray00).uiColor
        subheaderLabel.font = GlassFont.body2().uiFont
        subheaderLabel.textColor = (customEnabledForegroundColor ?? GlassColor.gray00).uiColor
        iconView.tintColor = (customEnabledForegroundColor ?? GlassColor.gray00).uiColor

        setBackgroundColor((customEnabledBackgroundColor ?? GlassColor.blue100).uiColor,
                           for: .normal)
        setBackgroundColor((customHighlightedBackgroundColor ?? GlassColor.blue160).uiColor,
                           for: .highlighted)
        setBackgroundColor((customDisabledBackgroundColor ?? GlassColor.gray50).uiColor,
                           for: .disabled)

        layer.cornerRadius = GlassBannerButton.bannerCornerRadius
    }

    func setAccessibility() {
        var lableTitle: String = ""
        if let primaryLabelText = primaryLabel.text {
            lableTitle += primaryLabelText
        }
        if let subheaderLabelText = subheaderLabel.text {
            lableTitle += " \(subheaderLabelText)"
        }

        self.accessibilityLabel = lableTitle

    }
}
// swiftlint:enable file_length

//======================================
// MARK: - Test Hooks
//======================================
#if DEBUG
extension GlassPrimaryButton {

    var _activityIndicator: GlassActivityIndicator { activityIndicator }
}
#endif
