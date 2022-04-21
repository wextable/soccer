//
//  GlassSwiftUILabel.swift
//  GlassUI
//
//  Created by Amisha Chordia on 21/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

public class GlassSwiftUILabelModel: ObservableObject {
    @Published public var text: String?
    @Published public var labelStyle: GlassLabelStyle
    @Published public var edgeInsets: EdgeInsets
    @Published public var containsPII: Bool
    @Published public var foregroundColor: Color?
    @Published fileprivate var isObfuscated: Bool = false

    public init(text: String? = nil,
                style: GlassLabelStyle = .displayText1,
                foregroundColor: Color? = nil,
                edgeInsets: EdgeInsets = .init(),
                containsPII: Bool = false) {
        self.text = text
        self.labelStyle = style
        self.foregroundColor = foregroundColor ?? style.textColor.swiftUIColor
        self.edgeInsets = edgeInsets
        self.containsPII = containsPII
    }
}

public struct GlassSwiftUILabel: View {
    @ObservedObject var dataModel: GlassSwiftUILabelModel
    @State private var obfuscatedText: String = ""

    private func shouldObfuscatePII(obfuscate: Bool) {
        guard dataModel.containsPII else { return }
        if obfuscate && !dataModel.isObfuscated {
            obfuscatedText = dataModel.text ?? ""
            dataModel.text = ""
        } else if !obfuscate && dataModel.isObfuscated {
            dataModel.text = obfuscatedText
            obfuscatedText = ""
        }
        dataModel.isObfuscated = obfuscate
    }

    public init(model: GlassSwiftUILabelModel) {
        self.dataModel = model
    }

    public var body: some View {
        if let text = dataModel.text {
            Text(text)
                .foregroundColor(dataModel.foregroundColor)
                .font(dataModel.labelStyle.font.swiftUIFont)
                .onReceive(.obfuscationNotification, perform: { _ in
                    shouldObfuscatePII(obfuscate: true)
                })
                .onReceive(.deobfuscationNotification) { _ in
                    shouldObfuscatePII(obfuscate: false)
                }
                .padding(dataModel.edgeInsets)
        }
    }
}

#if DEBUG
struct GlassSwiftUILabel_Previews: PreviewProvider {
    static var previews: some View {
        GlassSwiftUILabel(model: GlassSwiftUILabelModel(text: "My SwiftUI GlassLabel",
                                                        style: .heading,
                                                        foregroundColor: Color.purple,
                                                        edgeInsets: EdgeInsets(top: 10,
                                                                               leading: 0,
                                                                               bottom: 20,
                                                                               trailing: 20),
                                                        containsPII: true))
    }
}

extension GlassSwiftUILabel {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassSwiftUILabel

        fileprivate init(target: GlassSwiftUILabel) {
            self.target = target
        }

        func shouldObfuscatePII(obfuscate: Bool) {
            target.shouldObfuscatePII(obfuscate: obfuscate)
        }
    }
}
#endif
