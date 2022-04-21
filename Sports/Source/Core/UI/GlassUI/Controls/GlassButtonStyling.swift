//
//  GlassButtonStyling.swift
//  GlassUI
//
//  Created by Amisha Chordia on 28/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

/// Common styling for GlassButton
public enum GlassButtonStyle: CaseIterable {
    case large
    case small

    public var buttonSize: CGSize {
        switch self {
        case .small: return .init(width: 155, height: 32)
        case .large: return .init(width: 343, height: 40)
        }
    }

    public var cornerRadius: CGFloat {
        return buttonSize.height / 2
    }

    public var contentInset: CGFloat {
        switch self {
        case .small: return 16
        case .large: return 24
        }
    }
}

/// SwiftUI ObservableObject for custom button styling
public class GlassSwiftUIButtonStyle: ObservableObject {
    @Published public var style: GlassButtonStyle

    /// Set this color to provide custom text color for colored buttons
    /// Set customDisabledForegroundColor along with customEnabledForegroundColor
    @Published public var customEnabledForegroundColor: GlassColor?

    /// Set this color to provide custom text color for colored disabled buttons
    /// Set customEnabledForegroundColor along with customDisabledForegroundColor
    @Published public var customDisabledForegroundColor: GlassColor?

    /// Set this color to provide custom background color for enabled buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    @Published public var customEnabledBackgroundColor: GlassColor?

    /// Set this color to provide custom background color for highlighted buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    @Published public var customHighlightedBackgroundColor: GlassColor?

    /// Set this color to provide custom background color for disabled buttons
    /// Set customEnabledBackgroundColor, customHighlightedBackgroundColor, and customDisabledBackgroundColor
    @Published public var customDisabledBackgroundColor: GlassColor?

    public init(style: GlassButtonStyle = .large,
                customEnabledForegroundColor: GlassColor? = .white,
                customDisabledForegroundColor: GlassColor? = .white,
                customEnabledBackgroundColor: GlassColor? = .blue100,
                customHighlightedBackgroundColor: GlassColor? = .blue160,
                customDisabledBackgroundColor: GlassColor? = .gray50) {
        self.style = style
        self.customEnabledForegroundColor = customEnabledForegroundColor
        self.customDisabledForegroundColor = customDisabledForegroundColor
        self.customEnabledBackgroundColor = customEnabledBackgroundColor
        self.customHighlightedBackgroundColor = customHighlightedBackgroundColor
        self.customDisabledBackgroundColor = customDisabledBackgroundColor
    }
}

/// SwiftUI button styling for primary, secondary, banner, any other button
struct GlassSwiftUIButton: ButtonStyle {
    @ObservedObject var style: GlassSwiftUIButtonStyle

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        GlassButton(configuration: configuration, style: style)
    }

    struct GlassButton: View {
        let configuration: ButtonStyle.Configuration
        var style: GlassSwiftUIButtonStyle

        var foregroundColor: Color? {
            return isEnabled ?
                style.customEnabledForegroundColor?.swiftUIColor :
                style.customDisabledForegroundColor?.swiftUIColor
        }

        var backgroundColor: Color? {
            if !isEnabled {
                return style.customDisabledBackgroundColor?.swiftUIColor
            }
            if configuration.isPressed {
                return style.customHighlightedBackgroundColor?.swiftUIColor
            }
            return style.customEnabledBackgroundColor?.swiftUIColor
        }

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
        }
    }
}
