//
//  GlassCardsRow.swift
//  GlassUI
//
//  Created by Jose Garzadiaz on 4/24/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A horizontal stack view that renders a row of `GlassCard` components with arbitrary content.
///
/// [Zeplin reference](https://zpl.io/VqJxqMG)
open class GlassCardsRow: UIStackView, ViewConstructable {

    public var model: GlassCard.Model? {
        didSet { applyModel() }
    }

    /// Creates an instance of `GlassCardsRow` with an optional card model override.
    /// - Parameter model: The desired style of each card. If not provided, an appropriate style will be chosen.and
    ///   updated automatically based on the number of cards in the card row.
    public init(model: GlassCard.Model? = nil) {
        self.model = model
        super.init(frame: .zero)
        construct()
    }

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func constructView() {
        distribution = .fillEqually
        spacing = GlassSpacing.small
        translatesAutoresizingMaskIntoConstraints = false
    }

    open func constructSubviewHierarchy() { /* No-op */ }
    open func constructSubviewLayoutConstraints() { /* No-op */ }

    /// Applies the currently set model to every card in the card row. If there is no custom model set, an
    /// appropriate one will be computed based on the number of cards in the card row.
    ///
    /// - Important: It should not be necessary to call this function directly.
    open func applyModel() {
        guard !arrangedCards.isEmpty else { return }

        let style = GlassCard.Style(rawValue: arrangedCards.count) ?? .quarter
        let model = self.model ?? GlassCard.Model(style: style)
        arrangedCards.forEach { $0.model = model }
    }

    /// The list of cards arranged by the card row.
    open var arrangedCards: [GlassCard] {
        arrangedSubviews.compactMap { $0 as? GlassCard }
    }

    /// Add a card with the given contents to the card row.
    ///
    /// The correct card style will be automatically applied based on the new number of cards in the card row.
    /// - Parameter contentViews: The view or views that should be embedded in the created card.
    /// - Returns: The card that was created and added to the card row.
    @discardableResult
    open func addArrangedCard(withContent contentViews: UIView...) -> GlassCard {
        let card = GlassCard(model: .init(style: .full))
        card.addArrangedSubviews(contentViews)
        addArrangedSubview(card)
        applyModel()
        return card
    }
}
