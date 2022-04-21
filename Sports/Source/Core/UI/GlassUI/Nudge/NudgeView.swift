//
//  NudgeView.swift
//  GlassUI
//
//  Created by Hemanth Kumar on 05/03/21.
//

import UIKit

public protocol NudgeViewDelegate: AnyObject {
    func didTapOnClose(sender: NudgeView)
    func didTapOnLink(sender: NudgeView)
    func didTapOnNudge(sender: NudgeView)
}

/// Nudge View
/// ```swift
///   let model = NudgeView.NudgeViewModel(model: .init(title: NSAttributedString(string: "Title Name"),
///                                        message: NSAttributedString(string: "Message Description"),
///                                        icon: .spark,
///                                        detailsButtonTitle: "Do something",
///                                        isCloseButtonHidden: false))
///   let view = NudgeView(model: model)
/// ```
public class NudgeView: BaseView {
    private enum Constants {
        static let viewPadding: CGFloat = GlassSpacing.small
        static let rowPadding: CGFloat = GlassSpacing.xSmall
        static let iconSize: CGFloat = GlassSpacing.mediumLarge
        static let closeButtonSize: CGFloat = GlassSpacing.mediumSmall
    }

    private let nudgeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.backgroundColor = .clear
        stack.spacing = Constants.viewPadding
        stack.layer.cornerRadius = 8
        return stack
    }()

    private let dataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.backgroundColor = .clear
        stack.distribution = .fill
        stack.spacing = Constants.rowPadding
        return stack
    }()

    private let titleLabel: GlassLabel = {
        let label = GlassLabel(style: .heading)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.edgeInsets = .zero
        return label
    }()

    private let messageLabel: GlassLabel = {
        let label = GlassLabel(style: .body2)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.edgeInsets = .zero
        return label
    }()

    private let linkButton: GlassLinkButton = {
        let view = GlassLinkButton()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.backgroundColor = .clear
        closeButton.accessibilityLabel = "Close"
        let icon = GlassIcon.close.image(.custom(Constants.closeButtonSize))
        closeButton.setImage(icon,
                             for: .normal)
        return closeButton
    }()

    private let closeButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()

    private var tapGestureRecognizer: UIGestureRecognizer?

    public weak var delegate: NudgeViewDelegate?

    public var model: NudgeViewModel {
        didSet {
            applyModel()
        }
    }

    public init(model: NudgeViewModel) {
        self.model = model
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = true
        applyModel()
    }

    public override func constructView() {
        super.constructView()
        linkButton.addTarget(self, action: #selector(didTapOnLink), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        self.layer.cornerRadius = 8
        iconContainer.addAutoLayoutSubview(iconView)
        closeButtonContainer.addAutoLayoutSubview(closeButton)

        dataStackView.addArrangedSubview(titleLabel)
        dataStackView.addArrangedSubview(messageLabel)
        dataStackView.addArrangedSubview(linkButton)

        nudgeStackView.addArrangedSubview(iconContainer)
        nudgeStackView.addArrangedSubview(dataStackView)
        nudgeStackView.addArrangedSubview(closeButtonContainer)

        addAutoLayoutSubview(nudgeStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate([

            // Stack View
            nudgeStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPadding),
            nudgeStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(Constants.viewPadding)),
            nudgeStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.viewPadding),
            nudgeStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(Constants.viewPadding)),
            // Icon
            iconView.constraints(
                pinningTo: iconContainer,
                edges: [.leading, .top, .trailing]
            ),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),

            // Close Button
            closeButton.constraints(
                pinningTo: closeButtonContainer,
                edges: [.leading, .top, .trailing]
            ),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])
    }

    private func applyModel() {
        // View Config
        backgroundColor = model.decorator.backgroundColor

        // Icon Config
        iconContainer.isHidden = model.icon == nil
        iconView.image = model.icon?.image(.custom(Constants.iconSize)).withTintColor(model.decorator.iconColor)
        iconView.tintColor = model.decorator.iconColor

        // Title Label Config
        titleLabel.attributedText = model.title
        titleLabel.textColor = model.decorator.titleTextColor

        // Message Label Config
        messageLabel.isHidden = model.message == nil
        messageLabel.attributedText = model.message
        messageLabel.textColor = model.decorator.messageTextColor

        // Link Button Config
        linkButton.isHidden = model.detailsButtonTitle == nil
        linkButton.setTitle(model.detailsButtonTitle, for: .normal)
        linkButton.model = .init(size: .large, normalColor: model.decorator.linkButtonTitleColor)

        // Close Button Config
        closeButtonContainer.isHidden = model.isCloseButtonHidden

        // Accessibility
        isAccessibilityElement = model.isTappable
        accessibilityTraits = model.isTappable ? .button : .none
        accessibilityLabel = model.isTappable ? model.title.string : nil

        // Doing this async because it appears that attaching the gesture recognizer
        // does not work if called synchronously with NudgeView.init().
        DispatchQueue.main.async {
            if self.model.isTappable {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(self.didTapOnNudge))
                self.addGestureRecognizer(tapGestureRecognizer)
                self.tapGestureRecognizer = tapGestureRecognizer
            } else if let tapGestureRecognizer = self.tapGestureRecognizer {
                    self.removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        guard let superviewWidth = superview?.frame.size.width else {
            return .zero
        }

        var labelHeight: CGFloat = titleLabel.intrinsicContentSize.height

        labelHeight += messageLabel.isHidden ? 0 : (messageLabel.intrinsicContentSize.height + Constants.rowPadding)

        labelHeight += linkButton.isHidden ? 0 : (linkButton.intrinsicContentSize.height + Constants.rowPadding)

        return CGSize(width: superviewWidth, height: labelHeight + (Constants.viewPadding * 2) )
    }

    public override func layoutSubviews() {
        self.invalidateIntrinsicContentSize()
        super.layoutSubviews()
    }

    @objc func didTapCloseButton() {
        delegate?.didTapOnClose(sender: self)
    }

    @objc func didTapOnLink() {
        delegate?.didTapOnLink(sender: self)
    }

    @objc func didTapOnNudge() {
        delegate?.didTapOnNudge(sender: self)
    }
}

extension NudgeView {
    /// Message model for setting up Nudge View
    public struct NudgeViewModel {
        public let title: NSAttributedString
        public let message: NSAttributedString?
        public let icon: GlassIcon?
        public let detailsButtonTitle: String?
        public let isCloseButtonHidden: Bool
        /// Indicates whether the whole body of view should respond to taps. If set to `true`, those
        /// taps are communicated via `NudgeViewDelegate.didTapOnNudge()`.
        public let isTappable: Bool
        public let decorator: ViewDecorator
        public init(title: NSAttributedString,
                    message: NSAttributedString? = nil,
                    icon: GlassIcon? = nil,
                    detailsButtonTitle: String? = nil,
                    isCloseButtonHidden: Bool = true,
                    isTappable: Bool = false,
                    viewDecorator: ViewDecorator = .init()) {
            self.title = title
            self.message = message
            self.icon = icon
            self.detailsButtonTitle = detailsButtonTitle
            self.isCloseButtonHidden = isCloseButtonHidden
            self.isTappable = isTappable
            self.decorator = viewDecorator
        }
    }
}

extension NudgeView {
    public struct ViewDecorator {
        public let titleTextColor: UIColor
        public let messageTextColor: UIColor
        public let iconColor: UIColor
        public let linkButtonTitleColor: UIColor
        public let backgroundColor: UIColor

        public init(titleTextColor: UIColor = GlassColor.gray160.uiColor,
                    messageTextColor: UIColor = GlassColor.gray160.uiColor,
                    iconColor: UIColor = GlassColor.gray160.uiColor,
                    linkButtonTitleColor: UIColor = GlassColor.gray160.uiColor,
                    backgroundColor: UIColor = GlassColor.blue10.uiColor) {
            self.titleTextColor = titleTextColor
            self.messageTextColor = messageTextColor
            self.iconColor = iconColor
            self.linkButtonTitleColor = linkButtonTitleColor
            self.backgroundColor = backgroundColor
        }
    }
}
