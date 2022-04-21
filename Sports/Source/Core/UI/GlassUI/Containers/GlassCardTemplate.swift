//
//  GlassCardTemplate.swift
//  GlassUI
//
//  Created by Jose Garzadiaz on 4/27/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

public protocol GlassCardTemplateDelegate: AnyObject {
    /// Delegate method to know when user taps on a Button inside the Template
    ///
    /// - Parameters:
    ///   - button: Reference of the button that was pressed
    func buttonPressed(_ button: GlassButton)
}

/// A template card with a title, icon, subtitle, and action buttons. Additional content may be inserted between the
/// subtitle and action buttons.
///
/// [Zeplin reference](https://zpl.io/VqJxqMG)
public class GlassCardTemplate: GlassCard {

    public let titleLabel = GlassLabel(style: .displayText1)
    public let iconImageView = UIImageView()
    public let subtitleLabel = GlassLabel(style: .captionRegular)
    public let contentStackView = UIStackView(axis: .vertical)

    /// Use delegate to manage when the buttons are pressed
    public weak var delegate: GlassCardTemplateDelegate?

    private let dividerView = GlassDivider(style: .inCard)
    private let subtitleStackView = UIStackView()
    private let buttonsStackView = UIStackView()

    public override init(model: Model = .init(style: .full)) {
        super.init(model: model)
        self.setIcon(nil)
    }

    open override func constructView() {
        super.constructView()

        titleLabel.font = GlassFont.heading().uiFont
        titleLabel.textColor = GlassColor.gray100.uiColor

        iconImageView.contentMode = .scaleAspectFit

        subtitleLabel.font = GlassFont.body1().uiFont
        subtitleLabel.textColor = GlassColor.gray50.uiColor

        spacing = GlassSpacing.xSmall
        subtitleStackView.spacing = GlassSpacing.xxSmall
        buttonsStackView.spacing = GlassSpacing.small
    }

    open override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        addArrangedSubviews([titleLabel, subtitleStackView, contentStackView])
        subtitleStackView.addArrangedSubviews([iconImageView, subtitleLabel, UIView()])
        setCustomSpacing(GlassSpacing.xSmall, after: subtitleStackView)
    }

    /// Method to set the icon subtitle icon, if not icon is set this will be hidden
    ///
    /// - Parameters:
    ///   - icon: Reference of the icon to be displayed
    open func setIcon(_ icon: GlassIcon?) {
        iconImageView.image = icon?.imageSize16()?.withTintColor(GlassColor.gray50.uiColor)
        iconImageView.isHidden = icon == nil
    }

    /// Method to add a button to the Button Stack in the Template
    /// Use delegate to manage when the buttons are pressed
    ///
    /// - Parameters:
    ///   - title: title for the button to be displayed
    open func addButton(_ title: String) {
        if buttonsStackView.arrangedSubviews.isEmpty {
            addArrangedSubviews([dividerView, buttonsStackView])
            buttonsStackView.addArrangedSubview(UIView())
        }

        let button = GlassPrimaryButton()
        button.buttonStyle = .small
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(button)
    }

    @objc
    private func buttonPressed(_ button: GlassButton) {
        delegate?.buttonPressed(button)
    }
}

#if DEBUG
extension GlassCardTemplate {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassCardTemplate

        fileprivate init(target: GlassCardTemplate) {
            self.target = target
        }

        func mockButtonPressed(button: GlassButton) {
            target.buttonPressed(button)
        }
    }
}
#endif
