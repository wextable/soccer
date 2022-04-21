//
//  GlassSwiftUIBadge.swift
//  GlassUI
//
//  Created by Amisha Chordia on 01/06/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

public struct GlassSwiftUIBadge: View {

    private let model: GlassBadge.Model

    public init(model: GlassBadge.Model) {
        self.model = model
    }

    private var textColor: Color {
        switch model.style {
        case .outline:
            return model.badgeColor.swiftUIColor
        case .fill(let textColor):
            return textColor.swiftUIColor
        }
    }

    private var borderColor: Color {
        switch model.style {
        case .fill: return .clear
        case .outline: return model.badgeColor.swiftUIColor
        }
    }

    private var backgroundColor: Color {
        switch model.style {
        case .fill: return model.badgeColor.swiftUIColor
        case .outline: return GlassColor.gray00.swiftUIColor
        }
    }

    private struct LayoutMetrics {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 2
    }

    public var body: some View {
        HStack(spacing: GlassSpacing.xxSmall) {
            if let icon = model.icon {
                icon.swiftUIImage
                    .resizedImage(size: GlassIcon.Size.size12.cgSize)
                    .foregroundColor(textColor)
            }
            Text(model.text ?? "")
                .font(GlassFont.captionRegular().swiftUIFont)
                .foregroundColor(textColor)
        }.padding(EdgeInsets(top: GlassSpacing.xxSmall,
                             leading: GlassSpacing.xSmall,
                             bottom: GlassSpacing.xxSmall,
                             trailing: GlassSpacing.xSmall))
        .background(backgroundColor)
        .border(borderColor, width: LayoutMetrics.borderWidth)
        .cornerRadius(LayoutMetrics.cornerRadius)
    }
}

#if DEBUG

extension GlassSwiftUIBadge {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassSwiftUIBadge

        fileprivate init(target: GlassSwiftUIBadge) {
            self.target = target
        }

        var backgroundColor: Color { return target.backgroundColor }
        var borderColor: Color { return target.borderColor }
        var textColor: Color { return target.textColor }
    }
}

struct GlassSwiftUIBadgeViewPreview: PreviewProvider {

    static let badges: [GlassBadge.Model] = [
        .init(text: "Today", badgeColor: .green10, icon: .clock, style: .fill(textColor: .green100)),
        .init(text: "Tomorrow", badgeColor: .blue10, icon: .clock, style: .fill(textColor: .blue100)),
        .init(text: "2 Days", badgeColor: .gray10, icon: .clock, style: .fill(textColor: .gray100)),
        .init(text: "PG-13", badgeColor: .gray100, icon: .clock, style: .outline)
    ]

    static var previews: some View {
        List(Self.badges, id: \.text) { item in
            GlassSwiftUIBadge(model: item)
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
        .padding([.leading, .top], GlassSpacing.medium)
        .previewDevice("iPhone X")
    }
}
#endif
