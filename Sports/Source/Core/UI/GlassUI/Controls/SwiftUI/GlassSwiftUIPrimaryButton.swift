//
//  GlassSwiftUIPrimaryButton.swift
//  GlassUI
//
//  Created by Amisha Chordia on 23/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//
import SwiftUI

public class GlassSwiftUIPrimaryButtonModel: ObservableObject {
    /// A block which will be invoked after taps (`touchUpInside`)
    @Published public var onTap: GlassButtonTapHandler

    /// Button title
    @Published public var buttonTitleText: String

    /// Use this to opt out of formatting when setting this button's title.
    /// Perhaps you have a button which has a proper noun as its title. This might be a good place to set
    /// `button.titleHasCustomFormatting = true`
    public var titleHasCustomFormatting: Bool

    public init(buttonTitleText: String,
                titleHasCustomFormatting: Bool = false,
                onTap: @escaping GlassButtonTapHandler = {}) {
        self.titleHasCustomFormatting = titleHasCustomFormatting
        self.onTap = onTap
        self.buttonTitleText = buttonTitleText
    }
}

/// TODO: This primary button needs to have a loading state,
/// but we need the Spark view implemented in SwiftUI to introduce it here
public struct GlassSwiftUIPrimaryButton: View {
    @ObservedObject var model: GlassSwiftUIPrimaryButtonModel
    @ObservedObject var primaryButtonStyle: GlassSwiftUIButtonStyle

    public init(model: GlassSwiftUIPrimaryButtonModel, primaryButtonStyle: GlassSwiftUIButtonStyle = .init()) {
        self.model = model
        self.primaryButtonStyle = primaryButtonStyle
    }

    private var font: Font {
        primaryButtonStyle.style == .large ?
            GlassFont.subheading1().swiftUIFont :
            GlassFont.subheading2().swiftUIFont
    }

    public var body: some View {
        Button(action: model.onTap, label: {
            Text(format(toSentenceCase: model.buttonTitleText,
                        shouldFormat: !model.titleHasCustomFormatting))
                .frame(height: primaryButtonStyle.style.buttonSize.height)
                .padding(EdgeInsets(top: 0,
                                    leading: primaryButtonStyle.style.contentInset,
                                    bottom: 0,
                                    trailing: primaryButtonStyle.style.contentInset))
        })
        .font(font)
        .cornerRadius(primaryButtonStyle.style.cornerRadius)
        .buttonStyle(GlassSwiftUIButton(style: primaryButtonStyle))
    }
}

#if DEBUG

struct GlassSwiftUIPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        GlassSwiftUIPrimaryButton(model: GlassSwiftUIPrimaryButtonModel(buttonTitleText: "My primary button"))
    }
}

extension GlassSwiftUIPrimaryButton {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassSwiftUIPrimaryButton

        fileprivate init(target: GlassSwiftUIPrimaryButton) {
            self.target = target
        }

        var font: Font { return target.font }
    }
}

#endif
