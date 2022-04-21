//
//  ErrorViewController.swift
//  GlassUI
//
//  Created by John Regner on 11/30/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A nice little view controller for displaying various error states.
///
/// There are three predefined kinds of errors `generic`, `pageNotFound`, and `noInternet` though you could really use
/// this view for any type of error with a primary and optional secondary cta. Zeplin linked below.
///
/// Usage: Create one like you would any view controller, passing a model and setting up a button handler
/// ```
/// let model = ErrorViewController.Model(kind: .generic, ....)
/// let errorVC = ErrorViewController(model)
/// errorVC.primaryButtonHandler = { [weak self] in self.tryComplextThingAfterError() }
/// errorVC.viewWillAppearHandler = { [weak self] in self.performAnalyticsAfterViewWillAppear() }
/// present(errorVC)
/// ```
///
/// There are 3 default models that can be constructed as a usable model or as a starting point for mutation.
/// ```
/// var model = ErrorViewController.Model.defaultPageNotFound()
/// model.header = "Oh Nooooes. Page Not Found 404 Wahhhhh 😭"
/// let errorVC = ErrorViewController(model)
/// ```
///
/// Note that it is intentional that the page will show with a random image predefined for it's error `kind`
/// Zeplin: https://zpl.io/a3mxkgy
///
public final class ErrorViewController: BaseViewController {

    public struct Model {
        public enum Kind {
            case generic
            case pageNotFound
            case noInternet
            case rateLimiting
        }

        public var kind: Kind
        public var header: String
        public var body: String
        public var cta: String?
        public var secondaryButtonCTA: String?
        public var secondaryButtonHidden: Bool
        public var backgroundColor: UIColor? = .white

        var image: UIImage? {
            // swiftlint:disable:force_unwrap // non empty arrays will not crash
            switch kind {
            case .generic:
                let selected = ["truck", "cat", "dinosaur", "toaster"].randomElement()!
                return UIImage(named: "Error/error-generic-\(selected)",
                               in: .glassUIBundle, compatibleWith: nil)
            case .noInternet:
                let selected = ["cat", "device", "router", "sign", "tower"].randomElement()!
                return UIImage(named: "Error/error-no-internet-con-\(selected)",
                               in: .glassUIBundle, compatibleWith: nil)
            case .pageNotFound:
                let selected = ["search", "tv", "walking"].randomElement()!
                return UIImage(named: "Error/error-page-not-found-\(selected)",
                               in: .glassUIBundle, compatibleWith: nil)

            case .rateLimiting:
                return UIImage(
                    named: "Error/error-rate-limiting-waiting-room",
                    in: .glassUIBundle,
                    compatibleWith: nil
                )
            // swiftlint:enable:force_unwrap
            }
        }
    }

    private let image: UIImageView
    private let titleLabel: GlassLabel
    private let subtitleLabel: GlassLabel
    private let primaryButton: GlassPrimaryButton
    private let primaryButtonContainer: ContainerView
    private let secondaryButton: GlassLinkButton

    private let stackView: UIStackView

    private let topSpaceView = UIView(frame: .zero)

    public var model: Model {
        didSet {
            applyModel()
        }
    }

    public var primaryButtonHandler: (() -> Void)?
    public var secondaryButtonHandler: (() -> Void)?
    public var viewWillAppearHandler: (() -> Void)?

    public init(_ model: Model) {

        self.model = model

        self.image = {
            let i = UIImageView()
            i.contentMode = .scaleAspectFit
            return i
        }()

        self.titleLabel = {
            let l = GlassLabel(style: .pageTitle)
            l.textAlignment = .center
            l.numberOfLines = 0
            l.accessibilityIdentifier = "ErrorViewController.TitleLabel"
            return l
        }()

        self.subtitleLabel = {
            let l = GlassLabel(style: .body2)
            l.numberOfLines = 0
            l.textAlignment = .center
            l.accessibilityIdentifier = "ErrorViewController.SubTitleLabel"
            return l
        }()

        self.primaryButton = GlassPrimaryButton(buttonStyle: .large)
        self.primaryButton.accessibilityIdentifier = "ErrorViewController.PrimaryButton"
        self.primaryButtonContainer = ContainerView(primaryButton, axis: .vertical, alignment: .center)

        self.secondaryButton = GlassLinkButton(model: .init())
        self.secondaryButton.accessibilityIdentifier = "ErrorViewController.SecondaryButton"

        self.stackView = {
            let s = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill)
            s.spacing = GlassSpacing.mediumLarge
            return s
        }()

        super.init(nibName: nil, bundle: nil)

        applyModel()
    }

    public override func constructView() {
        super.constructView()
        primaryButton.addTarget(self, action: #selector(primaryCTATapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryCTATapped), for: .touchUpInside)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearHandler?()
    }

    public override func constructSubviewHierarchy() {
        view.addAutoLayoutSubview(topSpaceView)
        view.addAutoLayoutSubview(stackView)

        stackView.addArrangedSubviews([
            image,
            titleLabel,
            subtitleLabel,
            primaryButtonContainer,
            secondaryButton
        ])
    }

    public override func constructSubviewLayoutConstraints() {
        NSLayoutConstraint.activate([
            topSpaceView.heightAnchor.constraint(equalToConstant: GlassSpacing.medium),
            topSpaceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topSpaceView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpaceView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpaceView.bottomAnchor.constraint(equalTo: stackView.topAnchor)
        ])

        image.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        image.heightAnchor.constraint(lessThanOrEqualToConstant: 224.0).activate()

        updateStackViewSpacing()

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(
                equalTo: view.readableContentGuide.widthAnchor,
                constant: -GlassSpacing.medium
            ),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.constraints(pinningInside: view, edges: [.leading, .trailing]),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GlassSpacing.medium)
        ])

    }

    public override func willTransition(to newCollection: UITraitCollection,
                                        with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateStackViewSpacing()
    }

    private func updateStackViewSpacing() {
        stackView.spacing = UIScreen.main.isLandscape() ? GlassSpacing.small : GlassSpacing.mediumLarge
        stackView.setCustomSpacing(UIScreen.main.isLandscape() ? GlassSpacing.xSmall : GlassSpacing.medium,
                                   after: titleLabel)
        stackView.setCustomSpacing(UIScreen.main.isLandscape() ? GlassSpacing.xSmall : GlassSpacing.medium,
                                   after: primaryButtonContainer)
    }

    private func applyModel() {
        image.image = model.image
        titleLabel.text = model.header
        subtitleLabel.text = model.body
        primaryButton.setTitle(model.cta, for: .normal)
        primaryButton.isHidden = model.cta == nil
        secondaryButton.setTitle(model.secondaryButtonCTA, for: .normal)
        secondaryButton.isHidden = model.secondaryButtonHidden
        view.backgroundColor = model.backgroundColor
    }

    @objc
    private func primaryCTATapped() {
        primaryButtonHandler?()
    }

    @objc
    private func secondaryCTATapped() {
        secondaryButtonHandler?()
    }
}

public extension ErrorViewController.Model {
    static func defaultGeneric() -> ErrorViewController.Model {
        return ErrorViewController.Model(kind: .generic,
                                         header: "error-view-controller.generic.header".localize(),
                                         body: "error-view-controller.generic.body".localize(),
                                         cta: "error-view-controller.generic.cta".localize(),
                                         secondaryButtonCTA: "error-view-controller.generic.cta2".localize(),
                                         secondaryButtonHidden: false,
                                         backgroundColor: .white)
    }
    static func defaultPageNotFound() -> ErrorViewController.Model {
        return ErrorViewController.Model(kind: .pageNotFound,
                                         header: "error-view-controller.page-not-found.header".localize(),
                                         body: "error-view-controller.page-not-found.body".localize(),
                                         cta: "error-view-controller.page-not-found.cta".localize(),
                                         secondaryButtonCTA: nil,
                                         secondaryButtonHidden: true,
                                         backgroundColor: .white)
    }
    static func defaultNoInternet() -> ErrorViewController.Model {
        return ErrorViewController.Model(kind: .noInternet,
                                         header: "error-view-controller.no-internet.header".localize(),
                                         body: "error-view-controller.no-internet.body".localize(),
                                         cta: "error-view-controller.no-internet.cta".localize(),
                                         secondaryButtonCTA: nil,
                                         secondaryButtonHidden: true,
                                         backgroundColor: .white)
    }

    /// The default messaging for a rate limiting error (status code 429).
    static func defaultRateLimiting() -> ErrorViewController.Model {
        ErrorViewController.Model(
            kind: .rateLimiting,
            header: "error-view-controller.rate-limiting.header".localize(),
            body: "error-view-controller.rate-limiting.body".localize(),
            cta: nil,
            secondaryButtonCTA: nil,
            secondaryButtonHidden: true,
            backgroundColor: .white
        )
    }
}

#if DEBUG
extension ErrorViewController {
    var testHooks: TestHooks {
        .init(target: self)
    }

    struct TestHooks {
        let target: ErrorViewController

        var image: UIImage? {
            target.image.image
        }

        var titleText: String {
            target.titleLabel.text ?? ""
        }

        var subtitleText: String {
            target.subtitleLabel.text ?? ""
        }

        var primaryCTAText: String {
            target.primaryButton.title(for: .normal) ?? ""
        }

        var secondaryCTAText: String {
            target.secondaryButton.title(for: .normal) ?? ""
        }

        var secondaryButtonisHidden: Bool {
            target.secondaryButton.isHidden
        }

        var primaryButton: UIButton {
            target.primaryButton
        }

        var secondaryButton: UIButton {
            target.secondaryButton
        }
    }
}
#endif
