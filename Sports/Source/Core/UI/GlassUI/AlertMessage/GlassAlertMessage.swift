//
//  GlassAlertMessage.swift
//  GlassUI
//
//  Created by Joshua Mann on 5/14/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public protocol GlassAlertMessageDelegate: AnyObject {
    func didSelectRightButton(sender: GlassAlertMessage)

    /// Called when the alert's model has `isTappable=true` and the user taps anywhere on the alert.
    func didTapAlert(sender: GlassAlertMessage)
}

/// The standard vertical tile for displaying product information.
///
/// # Reference
/// [Zeplin](https://zpl.io/2G0DllE)

/// Message types with associated background color
public enum GlassMessageType: Equatable {
    case success
    case error
    case warning
    case information

    var iconColor: GlassColor {
        switch self {
        case .success:
            return .green130
        case .warning:
            return .spark160
        case .information:
            return .gray200
        case .error:
            return .red130
        }
    }

    var textColor: GlassColor {
        switch self {
        case .success:
            return .green130
        case .warning:
            return .spark160
        case .information:
            return .gray200
        case .error:
            return .red130
        }
    }

    var borderColor: GlassColor? {
        switch self {
        case .success:
            return .green50
        case .error:
            return .red50
        case .warning:
            return .spark50
        case .information:
            return .gray50
        }
    }

    var backgroundColor: GlassColor {
        switch self {
        case .success:
            return .green10
        case .error:
            return .red10
        case .warning:
            return .spark10
        case .information:
            return .gray10
        }
    }

    var leftColor: GlassColor? {
        switch self {
        case .success:
            return .green100
        case .error:
            return .red100
        case .warning:
            return .spark100
        case .information:
            return .gray200
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error),
             (.warning, .warning),
             (.success, .success),
             (.information, .information):
            return true
        default:
            return false
        }
    }
}

/// Glass Alert Message View
/// ```swift
///   let model = GlassAlertMessage.GlassAlertMessageModel(message:
///   NSAttributedString(string: "Test Alert Message"), messageType: .alert(.gray), image: nil)
///   let view = GlassAlertMessage(model: model)
/// ```
public class GlassAlertMessage: UIView {
    public weak var delegate: GlassAlertMessageDelegate?

    private enum Constants {
        static let outerCornerRadius: CGFloat = 4
        static let outerBorderWidth: CGFloat = 1
        static let columnPaddingV: CGFloat = 10 - outerBorderWidth
        static let leftLineWidth: CGFloat = 4 + outerBorderWidth
        static let columnSpacing: CGFloat = GlassSpacing.xSmall
        static let iconContainerWidth: CGFloat = 16
    }

    public var model: GlassAlertMessageModel {
        didSet {
            applyModel()
        }
    }

    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.backgroundColor = .clear
        stack.spacing = Constants.columnSpacing
        return stack
    }()

    let messageLabel: GlassLabel = {
        let label = GlassLabel(style: .body2)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.edgeInsets = .zero
        return label
    }()

    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    let rightButton: GlassLinkButton = {
        let view = GlassLinkButton()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    let leftAlignView: UIView = .init()
    let leftLineView: UIView = .init()
    let messageLabelContainer: UIView = .init()
    let rightButtonContainer: UIView = .init()
    let rightAlignView: UIView = .init()

    public var messageEdgeInsets: UIEdgeInsets? {
        get {
            return messageLabel.edgeInsets
        }
        set {
            messageLabel.edgeInsets = newValue
        }
    }

    private var tapGestureRecognizer: UIGestureRecognizer?

    public init(model: GlassAlertMessageModel) {
        self.model = model
        super.init(frame: .zero)
        setup()
        applyModel()
        setConstraints()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.masksToBounds = true

        iconContainer.addAutoLayoutSubview(iconView)
        rightButtonContainer.addAutoLayoutSubview(rightButton)
        messageLabelContainer.addAutoLayoutSubview(messageLabel)

        stackView.addArrangedSubview(leftAlignView)
        stackView.addArrangedSubview(leftLineView)
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(messageLabelContainer)
        stackView.addArrangedSubview(rightButtonContainer)
        stackView.addArrangedSubview(rightAlignView)
    }

    private func applyModel() {

        // View Config
        backgroundColor = model.messageType.backgroundColor.uiColor
        if let borderColor = model.messageType.borderColor?.uiColor.cgColor {
            layer.cornerRadius = Constants.outerCornerRadius
            layer.borderWidth = Constants.outerBorderWidth
            layer.borderColor = borderColor
        } else {
            layer.cornerRadius = 0
            layer.borderWidth = 0
        }

        // Left Line Config
        leftLineView.backgroundColor = model.messageType.leftColor?.uiColor
        leftLineView.isHidden = model.messageType.leftColor == nil
        leftAlignView.isHidden = !leftLineView.isHidden

        // Message Label Config
        messageLabel.attributedText = model.message
        messageLabel.textColor = model.messageType.textColor.uiColor
        if let verticalCompression = model.labelVerticalCompressionResistance {
            messageLabel.setContentCompressionResistancePriority(verticalCompression, for: .vertical)
        }

        // Icon Config
        iconContainer.isHidden = model.image == nil
        iconView.image = model.sizedImage?.withTintColor(model.messageType.iconColor.uiColor)
        iconView.tintColor = model.messageType.iconColor.uiColor

        // Right Button Config
        rightButtonContainer.isHidden = model.detailsButtonTitle == nil
        rightButton.setTitle(model.detailsButtonTitle, for: .normal)
        rightButton.model = .init(normalColor: model.messageType.textColor.uiColor)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)

        // Accessibility
        isAccessibilityElement = model.isTappable
        accessibilityTraits = model.isTappable ? .button : .none
        accessibilityLabel = model.isTappable ? model.message.string : nil

        // Doing this async because it appears that attaching the gesture recognizer
        // does not work if called synchronously with GlassAlertMessage.init().
        DispatchQueue.main.async {
            if self.model.isTappable {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapAlert))
                self.addGestureRecognizer(tapGestureRecognizer)
                self.tapGestureRecognizer = tapGestureRecognizer
            } else if let tapGestureRecognizer = self.tapGestureRecognizer {
                self.removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    /// Setting up constraints for the layout of the view
    private func setConstraints() {
        addAutoLayoutSubview(stackView)

        NSLayoutConstraint.activate([

            // Stack View
            stackView.constraints(pinningTo: self, edges: [.leading, .top, .bottom]),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -GlassSpacing.xSmall),

            // Left Line
            leftLineView.widthAnchor.constraint(equalToConstant: Constants.leftLineWidth),

            // Message Label
            messageLabel.constraints(
                pinningTo: messageLabelContainer,
                edges: .all,
                insets: .init(vertical: Constants.columnPaddingV)
            ),

            // Icon
            iconView.constraints(
                pinningTo: iconContainer,
                edges: [.leading, .top, .trailing],
                insets: .init(top: Constants.columnPaddingV)
            ),
            iconView.heightAnchor.constraint(equalTo: rightButton.heightAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: Constants.iconContainerWidth),

            // Right Button
            rightButton.constraints(
                pinningTo: rightButtonContainer,
                edges: [.leading, .top, .trailing],
                insets: .init(GlassSpacing.xSmall)
            ),

            // Aligned Views
            leftAlignView.widthAnchor.constraint(equalToConstant: 0),
            rightAlignView.widthAnchor.constraint(equalToConstant: 0)
        ])
    }

    public override var intrinsicContentSize: CGSize {
        guard let superviewWidth = superview?.frame.size.width else {
            return .zero
        }

        let labelHeight = messageLabel.intrinsicContentSize.height
        return CGSize(width: superviewWidth, height: labelHeight + Constants.columnPaddingV*2)
    }

    @objc func didTapRightButton() {
        self.delegate?.didSelectRightButton(sender: self)
    }

    @objc private func didTapAlert() {
        delegate?.didTapAlert(sender: self)
    }
}

extension GlassAlertMessage {

    /// Message model for setting up Message/Alert views
    public struct GlassAlertMessageModel: Equatable {
        public let message: NSAttributedString
        public let messageType: GlassMessageType
        public let image: GlassIcon?
        public let imageSize: GlassIcon.Size
        public let detailsButtonTitle: String?
        /// Indicates whether the whole body of alert should respond to taps. If set to `true`, those
        /// taps are communicated via `GlassAlertMessageDelegate.didTapAlert()`.
        public let isTappable: Bool
        /// If present, the alert message label will be configured with this vertical compression resistance.
        /// This is sometimes useful when the  Alert Message is in a vertically-constrained environment and
        /// you want to give vertical priority to the GlassAlertMessage over other elements.
        public let labelVerticalCompressionResistance: UILayoutPriority?

        public init(message: NSAttributedString,
                    messageType: GlassMessageType,
                    image: GlassIcon?,
                    imageSize: GlassIcon.Size = .size16,
                    detailsButtonTitle: String? = nil,
                    isTappable: Bool = false,
                    labelVerticalCompressionResistance: UILayoutPriority? = nil) {
            self.message = message
            self.messageType = messageType
            self.image = image
            self.imageSize = imageSize
            self.detailsButtonTitle = detailsButtonTitle
            self.isTappable = isTappable
            self.labelVerticalCompressionResistance = labelVerticalCompressionResistance
        }

        var sizedImage: UIImage? { return image?.image(imageSize) }
    }
}
