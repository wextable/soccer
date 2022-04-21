//
//  GlassCalloutView.swift
//  GlassUI
//
//  Created by Hemanth on 12/10/21.
//  Copyright © 2019 Walmart. All rights reserved.
//

import Combine
import Foundation
import UIKit

/// Zeplin Specs : https://zpl.io/bAKgM36
///
///          GlassCalloutTipView
/// ______________▲_________________
/// |  Get started by selecting     |
/// |   a size from the list.       |
/// |______________________Close______|
///

public protocol GlassCalloutViewDelegate: AnyObject {

    /// Callout View Appeared
    func calloutViewDidAppear(_ sender : GlassCalloutView)

    /// Dismissal of callout
    func didTapCloseButton(_ sender : GlassCalloutView)

    /// Tap on callout
    func didTapOnCallout(_ sender : GlassCalloutView)

    /// The callout dismissed automatically.
    func didAutoDismiss(_ sender : GlassCalloutView)
}

public class GlassCalloutView: BaseView {

    // MARK: Private members

    /// Reference view from which callout is displayed
    @objc private var referenceView: UIView

    /// Optional view to anchor the callout to. Useful if you want your callout to scroll with this view
    private var parentView: UIView?

    /// GlassCalloutTipView
    private weak var calloutTipView: GlassCalloutTipView?

    /// Preference to configure GlassCalloutTipView
    private var calloutPreference = GlassCalloutTipView.globalPreferences

    /// A Boolean indicating whether the callout has been manually dismissed.
    private var didDismiss = false

    /// A Boolean indicating whether the callout has been automatically dismissed.
    private var didAutoDismiss = false

    private var visibilityDetector: VisibilityDetector?
    private var visibilityTask: AnyCancellable?

    // MARK: Public members

    /// Delegate to receive call back on callout dismissal
    public weak var delegate: GlassCalloutViewDelegate?

    /// Configure attributes for callout
    private enum Constants {
        static let viewPadding: CGFloat     = GlassSpacing.small
        static let rowPadding: CGFloat      = GlassSpacing.xxSmall
        static let closeButtonSize: CGFloat = GlassSpacing.medium
        static let viewWidth: CGFloat       = 213.0
        static let arrowHeight: CGFloat     = GlassSpacing.xSmall
        static let arrowWidth: CGFloat      = GlassSpacing.small
        static let cornerRadius: CGFloat    = GlassSpacing.xxSmall
    }

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.backgroundColor = .clear
        stack.spacing = Constants.rowPadding
        return stack
    }()

    private let textLabel: GlassLabel = {
        let label = GlassLabel(style: .subheading1)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = GlassColor.white.uiColor
        label.edgeInsets = .zero
        return label
    }()

    private let closeLinkButton: GlassLinkButton = {
        let view = GlassLinkButton(model: .init(normalColor: GlassColor.white.uiColor,
                                                highlightedColor: GlassColor.white.uiColor))
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let linkButtonContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private var model: Model

    ///
    ///  Presents an GlassCalloutTipView pointing to a particular UIView instance within the specified superview
    ///- parameter model: An object describing the desired style of the CalloutView.
    ///- parameter sourceView: The UIView instance which the GlassCalloutTipView will be pointing to.
    ///- parameter parentView: A view that is part of the UIView instances superview hierarchy.
    ///                        Ignore this parameter in order to display the GlassCalloutTipView within the main window.
    ///                        (Note: recommended would be viewController's view which covers the entire window).
    ///
    required public init(model: Model,
                         sourceView: UIView,
                         parentView: UIView? = nil,
                         delegate: GlassCalloutViewDelegate? = nil) {
        self.model = model
        self.referenceView = sourceView
        self.parentView = parentView
        self.delegate = delegate
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: Constants.viewWidth,
                                 height: self.model.estimatedHeight))
        translatesAutoresizingMaskIntoConstraints = true
        applyViewModel()
    }

    public override func constructView() {
        super.constructView()
        closeLinkButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        updateAccessibility()
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        linkButtonContainer.addAutoLayoutSubview(closeLinkButton)
        contentStackView.addArrangedSubview(textLabel)
        contentStackView.addArrangedSubview(linkButtonContainer)

        addAutoLayoutSubview(contentStackView)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        var leadingConstant = Constants.viewPadding
        let trailingConstant = Constants.viewPadding
        var topConstant = Constants.viewPadding
        var bottonConstant = Constants.viewPadding
        switch model.preferredArrowDirection {
        case .any, .top, .topLeft, .topRight:
            topConstant += Constants.arrowHeight
        case .bottom, .bottomLeft, .bottomRight:
            bottonConstant += Constants.arrowHeight
        case .left:
            leadingConstant += Constants.arrowHeight
        default: break
        }

        NSLayoutConstraint.activate([

            contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingConstant),
            contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(trailingConstant)),
            contentStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: topConstant),
            contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(bottonConstant)),
            closeLinkButton.constraints(
                pinningTo: linkButtonContainer,
                edges: [.top, .trailing, .bottom]
            ),
            closeLinkButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            self.widthAnchor.constraint(equalToConstant: Constants.viewWidth)
        ])
    }

    private func applyViewModel() {
        textLabel.text = model.text
        closeLinkButton.setTitle(model.closeButtonText, for: .normal)
        configureCalloutPreference()
    }

    @objc private func didTapCloseButton() {
        dismissCallout()
        delegate?.didTapCloseButton(self)
    }

    // MARK: GlassCalloutTipView

    /// Configure preference for GlassCalloutTipView
    private func configureCalloutPreference() {
        calloutPreference.drawing.backgroundColor   = GlassColor.gray160.uiColor
        calloutPreference.drawing.arrowHeight       = Constants.arrowHeight
        calloutPreference.drawing.arrowWidth        = Constants.arrowWidth
        calloutPreference.drawing.cornerRadius      = Constants.cornerRadius
        calloutPreference.drawing.arrowPosition     = self.model.preferredArrowDirection
    }

    /// Setup & display GlassCalloutTipView from reference view
    public func showCalloutView() {
        let calloutTipView = GlassCalloutTipView(
            contentView: self,
            preferences: calloutPreference,
            delegate: self
        )

        // Disabling animation as we don't have any specs for animation
        calloutTipView.show(animated: false, forView: referenceView, withinSuperview: parentView)
        self.calloutTipView = calloutTipView
        delegate?.calloutViewDidAppear(self)

        UIAccessibility.post(notification: .layoutChanged, argument: textLabel)

        switch model.dismissBehavior {
        case .automatic:
            visibilityDetector = .init(view: self, visibilityThreshold: model.visibilityThreshold)
            visibilityTask = visibilityDetector?.visibilityPublisher
                .drop(untilOutputFrom: visibilityDetector!.visibilityPublisher.first(where: { $0 }))
                .first(where: { !$0 })
                .sink { [weak self] _ in
                    self?.autoDismissCallout()
                }

        case .manual:
            break
        }
    }

    /// Dismiss callout
    public func dismissCallout() {
        didDismiss = true
        calloutTipView?.dismiss()
    }

    private func autoDismissCallout() {
        guard model.dismissBehavior == .automatic else {
            return
        }

        guard !didDismiss, !didAutoDismiss else {
            return
        }

        didAutoDismiss = true
        calloutTipView?.dismiss()
        delegate?.didAutoDismiss(self)
    }

    // MARK: - Accessibility

    private func updateAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [textLabel, closeLinkButton].compactMap { $0 }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        // safety check in case the callout never became visible
        if window == nil {
            autoDismissCallout()
        }
    }
}

public extension GlassCalloutView {

    /// Direction of callout arrow
    ///
    /// - top: Arrow pointing upwards      ----🔼----
    /// - topLeft: Arrow pointing upwards      --🔼------
    /// - topRight: Arrow pointing upwards      ------🔼--
    /// - bottom: Arrow pointing downwards  ----🔽----
    /// - bottomLeft: Arrow pointing downwards  --🔽------
    /// - bottomRight: Arrow pointing downwards  ------🔽--
    /// - right: Arrow pointing right     -▶️
    /// - left: Arrow pointing left       ◀️
    /// - any: Defaults to arrow upwards  ----🔼----
    enum ArrowDirection {
        case top
        case topLeft
        case topRight
        case bottom
        case bottomLeft
        case bottomRight
        case right
        case left
        case any

        static let allValues = [top, topLeft, topRight, bottom, bottomLeft, bottomRight, right, left]
    }
}

// MARK: GlassCalloutTipViewDelegate

extension GlassCalloutView: GlassCalloutTipViewDelegate {
    func didTapOnCalloutView(_ calloutView: GlassCalloutTipView) {
        self.delegate?.didTapOnCallout(self)
    }

    func handleTapEvent(at point: CGPoint) {
        let translatedPoint = closeLinkButton.convert(point, from: superview)
        if closeLinkButton.bounds.contains(translatedPoint) {
            didTapCloseButton()
        } else {
            self.delegate?.didTapOnCallout(self)
        }
    }
}

// MARK: - GlassBubbleView ViewModel
extension GlassCalloutView {
    /// The model powering the Glass bubble view.
    public struct Model {

        /// Constants indicating how the callout can be dismissed.
        public enum DismissBehavior {

            /// The callout is dismissed when scrolled away or removed from a window.
            case automatic

            /// The callout can only be dismissed by the user tapping the close button.
            case manual
        }

        /// Text to be displayed in callout
        public var text: String

        /// Text to be displayed in callout
        public var closeButtonText: String

        /// Preferred arrow direction of callout
        public var preferredArrowDirection: ArrowDirection

        /// Preferred visibility threshold.
        ///
        /// The default is `half`.
        public var visibilityThreshold: VisibilityThreshold

        /// The behavior for determining when a callout is dismissed.
        ///
        /// The default value is `automatic`.
        public var dismissBehavior: DismissBehavior

        public init(
            text: String,
            closeButtonText: String = "Close",
            preferredArrowDirection: ArrowDirection = .left,
            visibilityThreshold: VisibilityThreshold = .half,
            dismissBehavior: DismissBehavior = .automatic
        ) {
            self.text = text
            self.closeButtonText = closeButtonText
            self.preferredArrowDirection = preferredArrowDirection
            self.visibilityThreshold  = visibilityThreshold
            self.dismissBehavior = dismissBehavior
        }

        lazy var estimatedHeight: CGFloat = {
            let textHeight = text.height(withConstrainedWidth: Constants.viewWidth - GlassSpacing.medium,
                                         font: GlassFont.subheading1().uiFont)
            return textHeight + Constants.viewPadding * 2 + Constants.closeButtonSize
        }()
    }

}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}

// MARK: - TestHooks
#if DEBUG
extension GlassCalloutView {
    var testHooks: TestHooks { TestHooks(target: self) }

    struct TestHooks {
        let target: GlassCalloutView

        var delegate: GlassCalloutViewDelegate? {
            return target.delegate
        }

        func callDidTapOnCloseButton() {
            target.didTapCloseButton()
        }
    }
}
#endif
