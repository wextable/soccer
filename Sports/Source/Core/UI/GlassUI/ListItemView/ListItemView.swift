//
//  ListItemView.swift
//  GlassUI
//
//  Created by Hemanth Kumar on 12/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import Foundation
import UIKit

public protocol ListItemViewDelegate: AnyObject {
    func didTapOnItem(sender: ListItemView)
}

/// List Item View
///
/// ```swift```
///   let model = ListItemView.Model(title: NSAttributedString(string: "Title Name"),
///                                  message: NSAttributedString(string: "Message Description"),
///                                  leftView: UIView(),
///                                  rightView: UIView(),
///                                  isTappable: false,
///                                  shouldHideSeparator: false)
///   let view = ListItemView(model: model)
/// ```
public class ListItemView: BaseView {
    private enum Constants {
        static let viewPadding: CGFloat = GlassSpacing.small
        static let rowPadding: CGFloat = GlassSpacing.xSmall
        static let iconSize: CGFloat = GlassSpacing.mediumLarge
        static let closeButtonSize: CGFloat = GlassSpacing.mediumSmall
    }

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.backgroundColor = .clear
        stack.spacing = Constants.viewPadding
        return stack
    }()

    private let dataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.backgroundColor = .clear
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()

    private let titleLabel: GlassLabel = {
        let label = GlassLabel(style: .subheading1)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.edgeInsets = .zero
        return label
    }()

    private let messageLabel: GlassLabel = {
        let label = GlassLabel(style: .body1)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.edgeInsets = .zero
        return label
    }()

    private let leftViewContainer: UIView = .init()
    private let rightViewContainer: UIView = .init()

    private let separatorView: GlassDivider = .init(style: .list)

    private var tapGestureRecognizer: UIGestureRecognizer?

    public weak var delegate: ListItemViewDelegate?

    public init(listItemModelProvider: ListItemViewModelProviding) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = true
        applyModel(with: listItemModelProvider.model)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        layer.masksToBounds = true

        dataStackView.addArrangedSubview(titleLabel)
        dataStackView.addArrangedSubview(messageLabel)

        containerStackView.addArrangedSubview(leftViewContainer)
        containerStackView.addArrangedSubview(dataStackView)
        containerStackView.addArrangedSubview(rightViewContainer)

        addAutoLayoutSubview(separatorView)
        addAutoLayoutSubview(containerStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate([

            // Stack View
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                        constant: Constants.viewPadding),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                         constant: -(Constants.viewPadding)),
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor,
                                                    constant: Constants.viewPadding),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                       constant: -(Constants.viewPadding)),

            //Separator View
            separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                   constant: Constants.viewPadding),
            separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                    constant: -(Constants.viewPadding)),
            separatorView.topAnchor.constraint(equalTo: self.containerStackView.bottomAnchor,
                                               constant: GlassSpacing.xSmall),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    private func applyModel(with model: ListItemView.Model) {
        // View Config
        backgroundColor = model.decorator.backgroundColor

        // Title Label Config
        titleLabel.isHidden = model.isTitleHidden
        titleLabel.attributedText = model.title
        titleLabel.textColor = model.decorator.titleTextColor

        // Message Label Config
        messageLabel.attributedText = model.message
        messageLabel.textColor = model.decorator.messageTextColor

        // Accessibility
        isAccessibilityElement = model.isTappable
        accessibilityTraits = model.accessibilityTraits()

        //Left View
        addAlighmentView(alignmentView: model.leftView, on: leftViewContainer)

        //Right View
        addAlighmentView(alignmentView: model.rightView, on: rightViewContainer)

        // Doing this async because it appears that attaching the gesture recognizer
        // does not work if called synchronously with ListItemView.init().
        DispatchQueue.main.async {
            if model.isTappable {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(self.didTapOnItem))
                self.addGestureRecognizer(tapGestureRecognizer)
                self.tapGestureRecognizer = tapGestureRecognizer
            } else if let tapGestureRecognizer = self.tapGestureRecognizer {
                    self.removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    private func addAlighmentView(alignmentView: AlignmentView?, on parentView: UIView) {
        if let alignmentView = alignmentView {
            parentView.isHidden = false
            parentView.addAutoLayoutSubview(alignmentView.view)
            NSLayoutConstraint.activate([
                alignmentView.view.topAnchor.constraint(lessThanOrEqualTo: parentView.topAnchor),
                alignmentView.view.bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor),
                alignmentView.view.leftAnchor.constraint(equalTo: parentView.leftAnchor),
                alignmentView.view.rightAnchor.constraint(equalTo: parentView.rightAnchor)
            ])
            if alignmentView.alignToCenter {
                NSLayoutConstraint.activate([
                    alignmentView.view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                    alignmentView.view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
                ])
            }
            if let width = alignmentView.width {
                NSLayoutConstraint.activate([alignmentView.view.widthAnchor.constraint(equalToConstant: width)])
            }
            if let height = alignmentView.height {
                NSLayoutConstraint.activate([alignmentView.view.heightAnchor.constraint(equalToConstant: height)])
            }
            self.layoutIfNeeded()
        } else {
            parentView.isHidden = true
        }
    }

    public func updateViewModel(with modelProvider: ListItemViewModelProviding) {
        applyModel(with: modelProvider.model)
    }

    @objc func didTapOnItem() {
        delegate?.didTapOnItem(sender: self)
    }
}

// users wishing to show their item in a list view must add this method so we know what to show where
public protocol ListItemViewModelProviding {
    var model: ListItemView.Model { get }
}

extension ListItemView {

    public struct AlignmentView {
        let view: UIView
        let width: CGFloat?
        let height: CGFloat?
        var alignToCenter: Bool = false

        public init(view: UIView,
                    width: CGFloat? = nil,
                    height: CGFloat? = nil,
                    alignToCenter: Bool = false) {
            self.view = view
            self.width = width
            self.height = height
            self.alignToCenter = alignToCenter
        }
    }

    /// Message model for setting up ListI tem View
    public struct Model {
        public let title: NSAttributedString?
        public let message: NSAttributedString
        public let leftView: AlignmentView?
        public let rightView: AlignmentView?
        /// Indicates whether the whole body of view should respond to taps. If set to `true`, those
        /// taps are communicated via `ListItemViewDelegate.didTapOnItem()`.
        public let isTappable: Bool
        public let shouldHideSeparator: Bool
        public let decorator: ViewDecorator
        public init(title: NSAttributedString? = nil,
                    message: NSAttributedString,
                    leftView: AlignmentView? = nil,
                    rightView: AlignmentView? = nil,
                    isTappable: Bool = false,
                    shouldHideSeparator: Bool = false,
                    viewDecorator: ViewDecorator = .init()) {
            self.title = title
            self.message = message
            self.leftView = leftView
            self.rightView = rightView
            self.isTappable = isTappable
            self.shouldHideSeparator = shouldHideSeparator
            self.decorator = viewDecorator
        }

        var isTitleHidden: Bool {
            title == nil
        }

        func accessibilityTraits() -> UIAccessibilityTraits {
            return isTappable ? .button : .none
        }
    }
}

extension ListItemView {
    public struct ViewDecorator {
        public let titleTextColor: UIColor
        public let messageTextColor: UIColor
        public let backgroundColor: UIColor

        public init(titleTextColor: UIColor = GlassColor.gray160.uiColor,
                    messageTextColor: UIColor = GlassColor.gray160.uiColor,
                    backgroundColor: UIColor = GlassColor.white.uiColor) {
            self.titleTextColor = titleTextColor
            self.messageTextColor = messageTextColor
            self.backgroundColor = backgroundColor
        }
    }
}

// MARK: - TestHooks

#if DEBUG
extension ListItemView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: ListItemView

        fileprivate init(target: ListItemView) {
            self.target = target
        }

        var titleText: String? { target.titleLabel.text }

        var messageText: String? { target.messageLabel.text }

        var leftView: UIView? { target.leftViewContainer.subviews.first }

        var rightView: UIView? { target.rightViewContainer.subviews.first }
    }
}
#endif
