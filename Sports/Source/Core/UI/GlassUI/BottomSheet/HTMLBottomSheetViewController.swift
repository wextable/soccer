//
//  HTMLBottomSheetViewController.swift
//  GlassUI
//
//  Created by Timothy Sears on 5/10/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public final class HTMLBottomSheetViewController: BaseViewController, BottomSheetable {

    // MARK: Properties

    private let titleLabel: GlassLabel
    private let scrollView: UIScrollView
    private let htmlLabel: UILabel
    private let closeButton: GlassPrimaryButton
    private let cancelButton: GlassLinkButton
    private let includeCancelButton: Bool

    // MARK: Initialization
    /// Creates a simple bottom sheet with a title label, scrollable stylized text that aheres to LD3.0 guidelines,
    /// and a Close button for self-dismissal.
    /// - Parameters:
    ///   - title: Should be a short string to help inform the user the context of the content being presented.
    ///   - html: HTML Text String to represent the formatted text. Try to keep it simple with stuff like bolded text,
    /// italics, etc and don't go too crazy with customization. We want to stay true to the design intent of LD3.0.
    public init(
        title: String,
        html: String,
        closeButtonTitle: String? = nil,
        includeCancelButton: Bool = false) throws
    {
        self.includeCancelButton = includeCancelButton

        titleLabel = {
            let label = GlassLabel(style: .subheading1)

            label.text = title
            label.numberOfLines = 0

            return label
        }()

        scrollView = {
            let scrollView = UIScrollView()

            return scrollView
        }()

        htmlLabel = {
            let label = UILabel()
            let data = Data(html.utf8)

            if let htmlString = NSMutableAttributedString.convertHtmlToAttributedString(data) {
                htmlString.settingFontFace(font: GlassFont.body2().uiFont)
                label.attributedText = htmlString
            }
            label.numberOfLines = 0

            return label
        }()

        closeButton = {
            let button = GlassPrimaryButton()

            button.setTitle(closeButtonTitle ?? "bottom-sheet.close.title".localize(), for: .normal)
            button.accessibilityLabel = "bottom-sheet.close.title".localize()

            return button
        }()

        cancelButton = {
            let button = GlassLinkButton()

            button.setTitle("bottom-sheet.cancel.title".localize(), for: .normal)

            return button
        }()

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Construction

    public override func constructView() {
        super.constructView()

        view.backgroundColor = GlassColor.gray00.uiColor

        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(titleLabel)
        view.addAutoLayoutSubview(scrollView)
        scrollView.addAutoLayoutSubview(htmlLabel)
        view.addAutoLayoutSubview(closeButton)

        if includeCancelButton {
            view.addAutoLayoutSubview(cancelButton)
        }
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()
        let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(
            equalToConstant: view.bounds.size.height * 0.6
        )
        scrollViewHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate(
            titleLabel.constraints(pinningTo: view, edges: [.top], insets: 0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: GlassSpacing.small),
            scrollView.constraints(pinningTo: view, edges: [.horizontal], insets: .init(GlassSpacing.small)),
            scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -GlassSpacing.small),
            scrollViewHeightConstraint,

            htmlLabel.constraints(pinningTo: scrollView),
            htmlLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        )

        if includeCancelButton {
            NSLayoutConstraint.activate(
                closeButton.constraints(pinningTo: view, edges: [.horizontal], insets: .init(GlassSpacing.small)),

                cancelButton.topAnchor.constraint(
                    equalTo: closeButton.bottomAnchor,
                    constant: .init(GlassSpacing.small)
                ),
                cancelButton.constraints(pinningTo: view, edges: [.horizontal], insets: .init(GlassSpacing.small)),
                cancelButton.constraints(pinningTo: view, edges: [.bottom], insets: .init(GlassSpacing.small))
            )
        } else {
            NSLayoutConstraint.activate(
                closeButton.constraints(pinningTo: view, edges: [.bottom], insets: .init(GlassSpacing.small)),
                closeButton.constraints(pinningTo: view, edges: [.horizontal], insets: .init(GlassSpacing.small))
            )
        }
    }

    // MARK: BottomSheetable

    public weak var bottomSheetableActionDelegate: BottomSheetableActionDelegate?

    public let maxBottomSheetHeight: CGFloat = UIScreen.main.bounds.size.height * 0.8
    public var contentView: UIView { return view }
    public var tiersType: BottomSheetTierType { return BottomSheetTierType.oneTierAutomatic }

    public var verticalScrollViews: [UIScrollView] { return [scrollView] }

    // MARK: Actions

    @objc
    private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc
    private func didTapCloseButton() {
        bottomSheetableActionDelegate?.triggerDismiss(self)
    }
}

#if DEBUG
extension HTMLBottomSheetViewController {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: HTMLBottomSheetViewController

        fileprivate init(target: HTMLBottomSheetViewController) {
            self.target = target
        }

        var titleLabel: GlassLabel { return target.titleLabel }
        var htmlLabel: UILabel { return target.htmlLabel }
        var scrollView: UIScrollView { return target.scrollView }
        var closeButton: GlassPrimaryButton { return target.closeButton }
        var cancelButton: GlassLinkButton { return target.cancelButton }

        func didTapCloseButton() {
            target.didTapCloseButton()
        }
    }
}
#endif
