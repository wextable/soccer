//
//  GlassProductCarouselLayout.swift
//  GlassUI
//
//  Created by John Liedtke on 5/14/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// A namespace for a collection of carousel layout factory methods.
///
/// See the demo app for an example usage. 
///
/// # Reference
/// [Zeplin](https://app.zeplin.io/project/5e913a56086f2c23293ebd03/screen/5ea399e8f6ee31bcc60bee29)
///
/// - Important: It is up to the consumer to configure the product tile's view model.
public final class GlassProductCarouselLayout {

    /// The carousel header kind identifier.
    public static let carouselHeaderKind = "carouselLayout.header.kind"

    /// The carousel footer kind identifier.
    public static let carouselFooterKind = "carouselLayout.footer.kind"

    /// An enumeration for the various styles of the carousel.
    public enum Style {

        /// A carousel that displays two full items and a peek of the third.
        case small

        /// A carousel that display two full items and most of a third item.
        case medium

        /// A carousel that displays three full items and a peek of the fourth.
        case regular
    }

    /// Creates the standard carousel layout of the specified style.
    ///
    /// - Parameters:
    ///   - style: The style of the carousel.
    ///   - boundarySupplementaryItems: Supplementary items of the carousel. The default value is a header and footer.
    public static func makeLayout(
        style: Style,
        boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = [makeHeader(), makeFooter()]
    ) -> UICollectionViewCompositionalLayout {
        let section = makeProductSection(style: style)

        section.interGroupSpacing = 0
        section.contentInsets.top = 0
        section.boundarySupplementaryItems = boundarySupplementaryItems

        return UICollectionViewCompositionalLayout(section: section)
    }

    /// Creates and returns the default carousel header supplementary header item.
    ///
    /// # Layout
    /// - Width: Full width
    /// - Height: Estimated height.
    ///
    /// Typically, you return an instance of `GlassProductCarouselHeaderView` in your `supplementaryViewProvider`.
    public static func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )

        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: Self.carouselHeaderKind,
            alignment: .topLeading
        )
    }

    /// Creates and returns the default carousel footer supplementary header item.
    ///
    /// # Layout
    /// - Width: Full width
    /// - Height: Estimated height.
    public static func makeFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
        )

        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: Self.carouselFooterKind,
            alignment: .bottomTrailing
        )
        return item
    }

    /// Creates and returns the default carousel product section of the specified style.
    ///
    /// Typically, you return an instance of `GlassProductTileCollectionCell` from your data source for the items
    /// in this section.
    public static func makeProductSection(style: Style, estimatedHeight: CGFloat = 200) -> NSCollectionLayoutSection {
        let estimatedHeight: CGFloat = estimatedHeight

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let fractionalWidth: CGFloat
        switch style {
        case .small: fractionalWidth = 0.29
        case .medium: fractionalWidth = 0.32
        case .regular: fractionalWidth = 0.38 //Third item is ~40% visible
        }

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(fractionalWidth),
                heightDimension: .estimated(estimatedHeight)
            ),
            subitems: [item]
        )

        let spacing: CGFloat.GlassSpacing
        switch style {
        case .regular, .medium: spacing = .xSmall
        case .small: spacing = .small
        }

        group.interItemSpacing = .fixed(spacing.rawValue)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = GlassSpacing.small
        section.contentInsets = .init(top: 0, leading: GlassSpacing.small, bottom: 0, trailing: GlassSpacing.small)
        section.orthogonalScrollingBehavior = .continuous

        return section
    }
}
