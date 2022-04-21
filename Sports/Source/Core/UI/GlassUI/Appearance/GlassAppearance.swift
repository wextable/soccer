//
//  GlassAppearance.swift
//  GlassUI
//
//  Created by John Liedtke on 12/10/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

/// A namespace for GlassUI UIAppearance styling.
public enum GlassAppearance {

    /// Applies the Glass appearance styling to all the salient UIKit components.
    public static func applyAppearanceStyle() {
        let navBarAppearance = Self.navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        UIBarButtonItem.appearance().tintColor = GlassColor.gray00.uiColor
        UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [BottomSheetNavigationController.self]).tintColor = GlassColor.gray200.uiColor
        UINavigationBar.appearance().tintColor = GlassColor.gray00.uiColor

        let tabBarAppearance = Self.tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().isTranslucent = false
        if #available(iOS 15, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    /// The standard glass navigation bar appearance.
    public static var navigationBarAppearance: UINavigationBarAppearance {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.backgroundColor = GlassColor.blue100.uiColor
        navBarAppearance.shadowColor = .clear

        let backButtonAppearance = UIBarButtonItemAppearance()
        let backButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.clear,
            .font: UIFont.systemFont(ofSize: 0.1)
        ]
        backButtonAppearance.normal.titleTextAttributes = backButtonTextAttributes
        backButtonAppearance.highlighted.titleTextAttributes = backButtonTextAttributes
        navBarAppearance.backButtonAppearance = backButtonAppearance

        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: GlassColor.gray00.uiColor,
            .font: GlassFont.heading().uiFont
        ]
        navBarAppearance.titleTextAttributes = textAttributes
        navBarAppearance.largeTitleTextAttributes = textAttributes

        navBarAppearance.buttonAppearance.normal.titleTextAttributes = textAttributes
        navBarAppearance.buttonAppearance.highlighted.titleTextAttributes = textAttributes

        let backIndicatorImage = navBarAppearance.backIndicatorImage
            .withAlignmentRectInsets(
                UIEdgeInsets(
                    top: 0,
                    left: -GlassSpacing.small,
                    bottom: 0,
                    right: 0
                )
            )

        navBarAppearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)

        return navBarAppearance
    }

    // The standard glass tab bar appearance.
    public static var tabBarAppearance: UITabBarAppearance {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()

        tabBarAppearance.backgroundColor = GlassColor.gray00.uiColor
        tabBarAppearance.stackedLayoutAppearance.applyGlassStyle()
        tabBarAppearance.inlineLayoutAppearance.applyGlassStyle()

        return tabBarAppearance
    }
}

private extension UITabBarItemAppearance {

    func applyGlassStyle() {
        normal.iconColor = GlassColor.gray100.uiColor
        normal.titleTextAttributes = [
            .foregroundColor: GlassColor.gray130.uiColor,
            .font: GlassFont.captionRegular().uiFont
        ]

        selected.iconColor = GlassColor.blue100.uiColor
        selected.titleTextAttributes = [
            .foregroundColor: GlassColor.blue100.uiColor,
            .font: GlassFont.captionRegular().uiFont
        ]
    }
}
