//
//  GlobalBanner.swift
//  GlassUI
//
//  Created by Hemanth Kumar on 05/03/21.
//

import UIKit

public protocol GlobalBannerDelegate: AnyObject {
    func didTapOnDetails(sender: GlobalBanner)
    func didTapOnBanner(sender: GlobalBanner)
}

/// Global Banner
/// ```swift
///   let model = GlobalBanner.GlobalBannerModel(
///      message: "Test Banner Message",
///      image: .star, detailsButtonTitle: "Learn more",
///      isTappable: true
///   ))
///   let view = GlassAlertMessage(model: model)
/// ```
public class GlobalBanner: UIView {
    public weak var delegate: GlobalBannerDelegate?

    private enum Constants {
        static let columnPaddingV: CGFloat = 16
        static let columnSpacing: CGFloat = GlassSpacing.xSmall
        static let iconContainerWidth: CGFloat = 16
    }

    public var model: GlobalBannerModel {
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
        let label = GlassLabel(style: .subheading1)
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

    public init(model: GlobalBannerModel) {
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
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(messageLabelContainer)
        stackView.addArrangedSubview(rightButtonContainer)
        stackView.addArrangedSubview(rightAlignView)
    }

    private func applyModel() {
        // View Config
        backgroundColor = model.decorator.backgroundColor
        // Message Label Config
        messageLabel.attributedText = model.message
        messageLabel.textColor = model.decorator.textColor

        // Icon Config
        iconContainer.isHidden = model.icon == nil
        iconView.image = model.icon?.imageSize16()?.withTintColor(model.decorator.iconColor)
        iconView.tintColor = model.decorator.iconColor

        // Right Button Config
        rightButtonContainer.isHidden = model.detailsButtonTitle == nil
        rightButton.setTitle(model.detailsButtonTitle, for: .normal)
        rightButton.model = .init(size: .large, normalColor: model.decorator.detailsButtonTitleColor)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)

        // Accessibility
        isAccessibilityElement = model.isTappable
        accessibilityTraits = model.isTappable ? .button : .none
        accessibilityLabel = model.isTappable ? model.message.string : nil

        // Doing this async because it appears that attaching the gesture recognizer
        // does not work if called synchronously with GlassAlertMessage.init().
        DispatchQueue.main.async {
            if self.model.isTappable {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTabOnBanner))
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
            stackView.constraints(pinningTo: self, edges: .all),

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
                insets: .init(top: Constants.columnPaddingV)
            ),

            // Aligned Views
            leftAlignView.widthAnchor.constraint(equalToConstant: 5),
            rightAlignView.widthAnchor.constraint(equalToConstant: 5)
        ])
    }

    public override var intrinsicContentSize: CGSize {
        guard let superviewWidth = superview?.frame.size.width else {
            return .zero
        }

        let labelHeight = messageLabel.intrinsicContentSize.height
        return CGSize(width: superviewWidth, height: labelHeight + Constants.columnPaddingV*2)
    }

    public override func layoutSubviews() {
        messageLabel.invalidateIntrinsicContentSize()
        self.invalidateIntrinsicContentSize()
        super.layoutSubviews()
    }

    @objc func didTapRightButton() {
        delegate?.didTapOnDetails(sender: self)
    }

    @objc func didTabOnBanner() {
        delegate?.didTapOnBanner(sender: self)
    }
}

extension GlobalBanner {
    /// Message model for setting up Message/Alert views
    public struct GlobalBannerModel {
        public let message: NSAttributedString
        public let icon: GlassIcon?
        public let detailsButtonTitle: String?
        /// Indicates whether the whole body of alert should respond to taps. If set to `true`, those
        /// taps are communicated via `GlobalBannerDelegate.didTabOnBanner()`.
        public let isTappable: Bool
        public let decorator: ViewDecorator
        public init(message: NSAttributedString,
                    icon: GlassIcon? = .none,
                    detailsButtonTitle: String? = nil,
                    isTappable: Bool = false,
                    viewDecorator: ViewDecorator = .init()) {
            self.message = message
            self.icon = icon
            self.detailsButtonTitle = detailsButtonTitle
            self.isTappable = isTappable
            self.decorator = viewDecorator
        }
    }
}

extension GlobalBanner {
    public struct ViewDecorator {
        public let textColor: UIColor
        public let iconColor: UIColor
        public let detailsButtonTitleColor: UIColor
        public let backgroundColor: UIColor

        public init(textColor: UIColor = .white,
                    iconColor: UIColor = .white,
                    detailsButtonTitleColor: UIColor = .white,
                    backgroundColor: UIColor = GlassColor.blue130.uiColor) {
            self.textColor = textColor
            self.iconColor = iconColor
            self.detailsButtonTitleColor = detailsButtonTitleColor
            self.backgroundColor = backgroundColor
        }
    }
}
