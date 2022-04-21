//
//  GlassSwiftUIIconButton.swift
//  GlassUI
//
//  Created by Amisha Chordia on 28/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

public class GlassSwiftUIIconButtonModel: ObservableObject {
    /// Icon to be set
    @Published public var icon: GlassIcon

    /// A block which will be invoked after taps (`touchUpInside`)
    @Published public var onTap: GlassButtonTapHandler

    public init(icon: GlassIcon,
                onTap: @escaping GlassButtonTapHandler = {}) {
        self.icon = icon
        self.onTap = onTap
    }
}

public struct GlassSwiftUIIconButton: View {
    @ObservedObject var model: GlassSwiftUIIconButtonModel
    @ObservedObject var iconButtonStyle: GlassSwiftUIButtonStyle

    public init(model: GlassSwiftUIIconButtonModel, iconButtonStyle: GlassSwiftUIButtonStyle = .init()) {
        self.model = model
        self.iconButtonStyle = iconButtonStyle
    }

    var buttonDimension: CGFloat {
        GlassButtonStyle.small.buttonSize.height
    }

    public var body: some View {
        Button(action: model.onTap, label: {
            model.icon
                .swiftUIImage
                .resizedImage(size: GlassIcon.Size.size16.cgSize,
                              withRenderingMode: .template)
                .padding(EdgeInsets(top: GlassSpacing.xSmall,
                                    leading: GlassSpacing.xSmall,
                                    bottom: GlassSpacing.xSmall,
                                    trailing: GlassSpacing.xSmall))
        })
        .frame(width: buttonDimension,
               height: buttonDimension)
        .cornerRadius(buttonDimension/2)
        .buttonStyle(GlassSwiftUIButton(style: iconButtonStyle))
    }
}

struct GlassSwiftUIIconButton_Previews: PreviewProvider {
    static var previews: some View {
        GlassSwiftUIIconButton(model: GlassSwiftUIIconButtonModel(icon: .bag))
    }
}
