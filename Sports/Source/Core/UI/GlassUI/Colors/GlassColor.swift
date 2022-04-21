//
//  GlassColor.swift
//  GlassUI
//
//  Created by Amisha Chordia on 17/06/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

/// All the colors from LD3. Supports both Color(from SwiftUI) and UIColor(from UIKit)
/// Reads from GlassColor.xcassets
///
/// ### Usage
/// **SwiftUI**
/// ```
/// GlassColor.red80.swiftUIColor
/// ```
/// **UIKit**
/// ```
/// GlassColor.red80.uiColor
/// ```
public class GlassColor {
    public let swiftUIColor: Color
    public let uiColor: UIColor

    public init(hex: String) {
        uiColor = UIColor(hex: hex)
        swiftUIColor = Color(uiColor)
    }

    public init(swiftUIColor: Color, uiColor: UIColor) {
        self.uiColor = uiColor
        self.swiftUIColor = swiftUIColor
    }

    public init(uiColor: UIColor) {
        self.uiColor = uiColor
        self.swiftUIColor = Color(uiColor)
    }

    @available(iOS 14.0, *)
    public init(swiftUIColor: Color) {
        self.swiftUIColor = swiftUIColor
        self.uiColor = UIColor(swiftUIColor)
    }

    private static func colorType(name: String) -> GlassColor {
        GlassColor(swiftUIColor: GlassColor.swiftUIColor(name: name),
                   uiColor: GlassColor.uiColor(name: name))
    }
}

extension GlassColor: Equatable {
    public static func == (lhs: GlassColor, rhs: GlassColor) -> Bool {
        lhs.uiColor == rhs.uiColor
    }
}

extension GlassColor: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uiColor)
    }
}

public extension GlassColor {
    static func swiftUIColor(name: String,
                             bundle: Bundle? = nil) -> Color {
        Color(name, bundle: bundle ?? .glassUIBundle)
    }

    static func uiColor(name: String,
                        bundle: Bundle? = nil,
                        traitCollection: UITraitCollection? = nil,
                        defaultColor: UIColor = .white) -> UIColor {
        UIColor(named: name,
                in: bundle ?? .glassUIBundle,
                compatibleWith: traitCollection) ?? defaultColor
    }
}

/// This should match the color names from GlassColor.xcassets
public extension GlassColor {
    ///Clear color
    static let clear: GlassColor = GlassColor.colorType(name: "clear")
    ///Hex value: #f2f8fd
    static let blue05: GlassColor = GlassColor.colorType(name: "blue05")
    ///Hex value: #e6f1fc
    static let blue10: GlassColor = GlassColor.colorType(name: "blue10")
    ///Hex value: #cce3f8
    static let blue20: GlassColor = GlassColor.colorType(name: "blue20")
    ///Hex value: #b3d4f5
    static let blue30: GlassColor = GlassColor.colorType(name: "blue30")
    ///Hex value: #99c6f1
    static let blue40: GlassColor = GlassColor.colorType(name: "blue40")
    ///Hex value: #80b8ee
    static let blue50: GlassColor = GlassColor.colorType(name: "blue50")
    ///Hex value: #66aaea
    static let blue60: GlassColor = GlassColor.colorType(name: "blue60")
    ///Hex value: #4d9ce7
    static let blue70: GlassColor = GlassColor.colorType(name: "blue70")
    ///Hex value: #338de3
    static let blue80: GlassColor = GlassColor.colorType(name: "blue80")
    ///Hex value: 1a7fe0
    static let blue90: GlassColor = GlassColor.colorType(name: "blue90")
    ///Hex value: #0071dc
    static let blue100: GlassColor = GlassColor.colorType(name: "blue100")
    ///Hex value: #0066c6
    static let blue110: GlassColor = GlassColor.colorType(name: "blue110")
    ///Hex value: #005ab0
    static let blue120: GlassColor = GlassColor.colorType(name: "blue120")
    ///Hex value: #004f9a
    static let blue130: GlassColor = GlassColor.colorType(name: "blue130")
    ///Hex value: #004484
    static let blue140: GlassColor = GlassColor.colorType(name: "blue140")
    ///Hex value: #00396e
    static let blue150: GlassColor = GlassColor.colorType(name: "blue150")
    ///Hex value: #002D58
    static let blue160: GlassColor = GlassColor.colorType(name: "blue160")
    ///Hex value: #002242
    static let blue170: GlassColor = GlassColor.colorType(name: "blue170")
    ///Hex value: #00172c
    static let blue180: GlassColor = GlassColor.colorType(name: "blue180")
    ///Hex value: #fdf4f4
    static let red05: GlassColor = GlassColor.colorType(name: "red05")
    ///Hex value: #fce8e9
    static let red10: GlassColor = GlassColor.colorType(name: "red10")
    ///Hex value: #f8d2d3
    static let red20: GlassColor = GlassColor.colorType(name: "red20")
    ///Hex value: #f5bbbd
    static let red30: GlassColor = GlassColor.colorType(name: "red30")
    ///Hex value: #f2a4a7
    static let red40: GlassColor = GlassColor.colorType(name: "red40")
    ///Hex value: #ef8e92
    static let red50: GlassColor = GlassColor.colorType(name: "red50")
    ///Hex value: #eb777c
    static let red60: GlassColor = GlassColor.colorType(name: "red60")
    ///Hex value: #e86066
    static let red70: GlassColor = GlassColor.colorType(name: "red70")
    ///Hex value: #e54950
    static let red80: GlassColor = GlassColor.colorType(name: "red80")
    ///Hex value: #e1333a
    static let red90: GlassColor = GlassColor.colorType(name: "red90")
    ///Hex value: #de1c24
    static let red100: GlassColor = GlassColor.colorType(name: "red100")
    ///Hex value: #c81920
    static let red110: GlassColor = GlassColor.colorType(name: "red110")
    ///Hex value: #b2161d
    static let red120: GlassColor = GlassColor.colorType(name: "red120")
    ///Hex value: #9B1419
    static let red130: GlassColor = GlassColor.colorType(name: "red130")
    ///Hex value: #851116
    static let red140: GlassColor = GlassColor.colorType(name: "red140")
    ///Hex value: #6f0e12
    static let red150: GlassColor = GlassColor.colorType(name: "red150")
    ///Hex value: #590B0E
    static let red160: GlassColor = GlassColor.colorType(name: "red160")
    ///Hex value: #43080b
    static let red170: GlassColor = GlassColor.colorType(name: "red170")
    ///Hex value: #2c0607
    static let red180: GlassColor = GlassColor.colorType(name: "red180")
    ///Hex value: #fff7f2
    static let orange05: GlassColor = GlassColor.colorType(name: "orange05")
    ///Hex value: #FFF0E6
    static let orange10: GlassColor = GlassColor.colorType(name: "orange10")
    ///Hex value: #fee0cc
    static let orange20: GlassColor = GlassColor.colorType(name: "orange20")
    ///Hex value: #fed1b3
    static let orange30: GlassColor = GlassColor.colorType(name: "orange30")
    ///Hex value: #fdc199
    static let orange40: GlassColor = GlassColor.colorType(name: "orange40")
    ///Hex value: #FDB280
    static let orange50: GlassColor = GlassColor.colorType(name: "orange50")
    ///Hex value: #fca266
    static let orange60: GlassColor = GlassColor.colorType(name: "orange60")
    ///Hex value: #fc934d
    static let orange70: GlassColor = GlassColor.colorType(name: "orange70")
    ///Hex value: #fb8333
    static let orange80: GlassColor = GlassColor.colorType(name: "orange80")
    ///Hex value: #fb741a
    static let orange90: GlassColor = GlassColor.colorType(name: "orange90")
    ///Hex value: #fa6400
    static let orange100: GlassColor = GlassColor.colorType(name: "orange100")
    ///Hex value: #e15a00
    static let orange110: GlassColor = GlassColor.colorType(name: "orange110")
    ///Hex value: #c85000
    static let orange120: GlassColor = GlassColor.colorType(name: "orange120")
    ///Hex value: #AF4600
    static let orange130: GlassColor = GlassColor.colorType(name: "orange130")
    ///Hex value: #963c00
    static let orange140: GlassColor = GlassColor.colorType(name: "orange140")
    ///Hex value: #7d3200
    static let orange150: GlassColor = GlassColor.colorType(name: "orange150")
    ///Hex value: #642800
    static let orange160: GlassColor = GlassColor.colorType(name: "orange160")
    ///Hex value: #4b1e00
    static let orange170: GlassColor = GlassColor.colorType(name: "orange170")
    ///Hex value: #321400
    static let orange180: GlassColor = GlassColor.colorType(name: "orange180")
    ///Hex value: #fffcf4
    static let spark05: GlassColor = GlassColor.colorType(name: "spark05")
    ///Hex value: #FFF9E9
    static let spark10: GlassColor = GlassColor.colorType(name: "spark10")
    ///Hex value: #fff3d2
    static let spark20: GlassColor = GlassColor.colorType(name: "spark20")
    ///Hex value: #ffedbc
    static let spark30: GlassColor = GlassColor.colorType(name: "spark30")
    ///Hex value: #ffe7a6
    static let spark40: GlassColor = GlassColor.colorType(name: "spark40")
    ///Hex value: #FFE190
    static let spark50: GlassColor = GlassColor.colorType(name: "spark50")
    ///Hex value: #ffda79
    static let spark60: GlassColor = GlassColor.colorType(name: "spark60")
    ///Hex value: #ffd463
    static let spark70: GlassColor = GlassColor.colorType(name: "spark70")
    ///Hex value: #ffce4d
    static let spark80: GlassColor = GlassColor.colorType(name: "spark80")
    ///Hex value: #ffc836
    static let spark90: GlassColor = GlassColor.colorType(name: "spark90")
    ///Hex value: #ffc220
    static let spark100: GlassColor = GlassColor.colorType(name: "spark100")
    ///Hex value: #e6af1d
    static let spark110: GlassColor = GlassColor.colorType(name: "spark110")
    ///Hex value: #cc9b1a
    static let spark120: GlassColor = GlassColor.colorType(name: "spark120")
    ///Hex value: #B38816
    static let spark130: GlassColor = GlassColor.colorType(name: "spark130")
    ///Hex value: #997413
    static let spark140: GlassColor = GlassColor.colorType(name: "spark140")
    ///Hex value: #806110
    static let spark150: GlassColor = GlassColor.colorType(name: "spark150")
    ///Hex value: #664E0D
    static let spark160: GlassColor = GlassColor.colorType(name: "spark160")
    ///Hex value: #4d3a0a
    static let spark170: GlassColor = GlassColor.colorType(name: "spark170")
    ///Hex value: #332706
    static let spark180: GlassColor = GlassColor.colorType(name: "spark180")
    ///Hex value: #fffef2
    static let yellow05: GlassColor = GlassColor.colorType(name: "yellow05")
    ///Hex value: #FFFEE6
    static let yellow10: GlassColor = GlassColor.colorType(name: "yellow10")
    ///Hex value: #fffccc
    static let yellow20: GlassColor = GlassColor.colorType(name: "yellow20")
    ///Hex value: #fffbb3
    static let yellow30: GlassColor = GlassColor.colorType(name: "yellow30")
    ///Hex value: #fffa99
    static let yellow40: GlassColor = GlassColor.colorType(name: "yellow40")
    ///Hex value: #FFF980
    static let yellow50: GlassColor = GlassColor.colorType(name: "yellow50")
    ///Hex value: #fff766
    static let yellow60: GlassColor = GlassColor.colorType(name: "yellow60")
    ///Hex value: #fff64d
    static let yellow70: GlassColor = GlassColor.colorType(name: "yellow70")
    ///Hex value: #fff533
    static let yellow80: GlassColor = GlassColor.colorType(name: "yellow80")
    ///Hex value: #fff31a
    static let yellow90: GlassColor = GlassColor.colorType(name: "yellow90")
    ///Hex value: #fff200
    static let yellow100: GlassColor = GlassColor.colorType(name: "yellow100")
    ///Hex value: #e6da00
    static let yellow110: GlassColor = GlassColor.colorType(name: "yellow110")
    ///Hex value: #ccc200
    static let yellow120: GlassColor = GlassColor.colorType(name: "yellow120")
    ///Hex value: #B3A900
    static let yellow130: GlassColor = GlassColor.colorType(name: "yellow130")
    ///Hex value: #999100
    static let yellow140: GlassColor = GlassColor.colorType(name: "yellow140")
    ///Hex value: #807900
    static let yellow150: GlassColor = GlassColor.colorType(name: "yellow150")
    ///Hex value: #666100
    static let yellow160: GlassColor = GlassColor.colorType(name: "yellow160")
    ///Hex value: #4d4900
    static let yellow170: GlassColor = GlassColor.colorType(name: "yellow170")
    ///Hex value: #333000
    static let yellow180: GlassColor = GlassColor.colorType(name: "yellow180")
    ///Hex value: #fcf4f9
    static let pink05: GlassColor = GlassColor.colorType(name: "pink05")
    ///Hex value: #FAEAF4
    static let pink10: GlassColor = GlassColor.colorType(name: "pink10")
    ///Hex value: #f5d5e9
    static let pink20: GlassColor = GlassColor.colorType(name: "pink20")
    ///Hex value: #efc0de
    static let pink30: GlassColor = GlassColor.colorType(name: "pink30")
    ///Hex value: #eaabd3
    static let pink40: GlassColor = GlassColor.colorType(name: "pink40")
    ///Hex value: #E596C8
    static let pink50: GlassColor = GlassColor.colorType(name: "pink50")
    ///Hex value: #e080bc
    static let pink60: GlassColor = GlassColor.colorType(name: "pink60")
    ///Hex value: #db6bb1
    static let pink70: GlassColor = GlassColor.colorType(name: "pink70")
    ///Hex value: #d556a6
    static let pink80: GlassColor = GlassColor.colorType(name: "pink80")
    ///Hex value: #d0419b
    static let pink90: GlassColor = GlassColor.colorType(name: "pink90")
    ///Hex value: #cb2c90
    static let pink100: GlassColor = GlassColor.colorType(name: "pink100")
    ///Hex value: #b72882
    static let pink110: GlassColor = GlassColor.colorType(name: "pink110")
    ///Hex value: #a22373
    static let pink120: GlassColor = GlassColor.colorType(name: "pink120")
    ///Hex value: #8E1F65
    static let pink130: GlassColor = GlassColor.colorType(name: "pink130")
    ///Hex value: #7a1a56
    static let pink140: GlassColor = GlassColor.colorType(name: "pink140")
    ///Hex value: #661648
    static let pink150: GlassColor = GlassColor.colorType(name: "pink150")
    ///Hex value: #51123A
    static let pink160: GlassColor = GlassColor.colorType(name: "pink160")
    ///Hex value: #3d0d2b
    static let pink170: GlassColor = GlassColor.colorType(name: "pink170")
    ///Hex value: #29091d
    static let pink180: GlassColor = GlassColor.colorType(name: "pink180")
    ///Hex value: #f7f5f9
    static let purple05: GlassColor = GlassColor.colorType(name: "purple05")
    ///Hex value: #EFEBF2
    static let purple10: GlassColor = GlassColor.colorType(name: "purple10")
    ///Hex value: #e0d6e5
    static let purple20: GlassColor = GlassColor.colorType(name: "purple20")
    ///Hex value: #d0c2d8
    static let purple30: GlassColor = GlassColor.colorType(name: "purple30")
    ///Hex value: #c1adcb
    static let purple40: GlassColor = GlassColor.colorType(name: "purple40")
    ///Hex value: #B199BF
    static let purple50: GlassColor = GlassColor.colorType(name: "purple50")
    ///Hex value: #a184b2
    static let purple60: GlassColor = GlassColor.colorType(name: "purple60")
    ///Hex value: #9270a5
    static let purple70: GlassColor = GlassColor.colorType(name: "purple70")
    ///Hex value: #825b98
    static let purple80: GlassColor = GlassColor.colorType(name: "purple80")
    ///Hex value: #73478b
    static let purple90: GlassColor = GlassColor.colorType(name: "purple90")
    ///Hex value: #63327e
    static let purple100: GlassColor = GlassColor.colorType(name: "purple100")
    ///Hex value: #592d71
    static let purple110: GlassColor = GlassColor.colorType(name: "purple110")
    ///Hex value: #4f2865
    static let purple120: GlassColor = GlassColor.colorType(name: "purple120")
    ///Hex value: #452358
    static let purple130: GlassColor = GlassColor.colorType(name: "purple130")
    ///Hex value: #3b1e4c
    static let purple140: GlassColor = GlassColor.colorType(name: "purple140")
    ///Hex value: #32193f
    static let purple150: GlassColor = GlassColor.colorType(name: "purple150")
    ///Hex value: #281432
    static let purple160: GlassColor = GlassColor.colorType(name: "purple160")
    ///Hex value: #1e0f26
    static let purple170: GlassColor = GlassColor.colorType(name: "purple170")
    ///Hex value: #140a19
    static let purple180: GlassColor = GlassColor.colorType(name: "purple180")
    ///Hex value: #f4f9f2
    static let green05: GlassColor = GlassColor.colorType(name: "green05")
    ///Hex value: #EAF3E6
    static let green10: GlassColor = GlassColor.colorType(name: "green10")
    ///Hex value: #d4e7cd
    static let green20: GlassColor = GlassColor.colorType(name: "green20")
    ///Hex value: #bfdbb3
    static let green30: GlassColor = GlassColor.colorType(name: "green30")
    ///Hex value: #aacf9a
    static let green40: GlassColor = GlassColor.colorType(name: "green40")
    ///Hex value: #95C381
    static let green50: GlassColor = GlassColor.colorType(name: "green50")
    ///Hex value: #7fb768
    static let green60: GlassColor = GlassColor.colorType(name: "green60")
    ///Hex value: #6aab4f
    static let green70: GlassColor = GlassColor.colorType(name: "green70")
    ///Hex value: #559f35
    static let green80: GlassColor = GlassColor.colorType(name: "green80")
    ///Hex value: #3f931c
    static let green90: GlassColor = GlassColor.colorType(name: "green90")
    ///Hex value: #2a8703
    static let green100: GlassColor = GlassColor.colorType(name: "green100")
    ///Hex value: #267a03
    static let green110: GlassColor = GlassColor.colorType(name: "green110")
    ///Hex value: #226c02
    static let green120: GlassColor = GlassColor.colorType(name: "green120")
    ///Hex value: #1D5F02
    static let green130: GlassColor = GlassColor.colorType(name: "green130")
    ///Hex value: #195102
    static let green140: GlassColor = GlassColor.colorType(name: "green140")
    ///Hex value: #154402
    static let green150: GlassColor = GlassColor.colorType(name: "green150")
    ///Hex value: #113601
    static let green160: GlassColor = GlassColor.colorType(name: "green160")
    ///Hex value: #0d2901
    static let green170: GlassColor = GlassColor.colorType(name: "green170")
    ///Hex value: #081b01
    static let green180: GlassColor = GlassColor.colorType(name: "green180")
    ///Hex value: #ffffff White
    static let gray00: GlassColor = GlassColor.colorType(name: "gray00")
    ///Hex value: #f8f8f8
    static let gray05: GlassColor = GlassColor.colorType(name: "gray05")
    ///Hex value: #f1f1f2
    static let gray10: GlassColor = GlassColor.colorType(name: "gray10")
    ///Hex value: #e3e4e5
    static let gray20: GlassColor = GlassColor.colorType(name: "gray20")
    ///Hex value: #d5d6d8
    static let gray30: GlassColor = GlassColor.colorType(name: "gray30")
    ///Hex value: #c7c8cb
    static let gray40: GlassColor = GlassColor.colorType(name: "gray40")
    ///Hex value: #babbbe
    static let gray50: GlassColor = GlassColor.colorType(name: "gray50")
    ///Hex value: #acadb0
    static let gray60: GlassColor = GlassColor.colorType(name: "gray60")
    ///Hex value: #9e9fa3
    static let gray70: GlassColor = GlassColor.colorType(name: "gray70")
    ///Hex value: #909196
    static let gray80: GlassColor = GlassColor.colorType(name: "gray80")
    ///Hex value: #828489
    static let gray90: GlassColor = GlassColor.colorType(name: "gray90")
    ///Hex value: #74767c
    static let gray100: GlassColor = GlassColor.colorType(name: "gray100")
    ///Hex value: #686a70
    static let gray110: GlassColor = GlassColor.colorType(name: "gray110")
    ///Hex value: #5d5e63
    static let gray120: GlassColor = GlassColor.colorType(name: "gray120")
    ///Hex value: #515357
    static let gray130: GlassColor = GlassColor.colorType(name: "gray130")
    ///Hex value: #46474a
    static let gray140: GlassColor = GlassColor.colorType(name: "gray140")
    ///Hex value: #3a3b3e
    static let gray150: GlassColor = GlassColor.colorType(name: "gray150")
    ///Hex value: #2e2f32
    static let gray160: GlassColor = GlassColor.colorType(name: "gray160")
    ///Hex value: #232325
    static let gray170: GlassColor = GlassColor.colorType(name: "gray170")
    ///Hex value: #171819
    static let gray180: GlassColor = GlassColor.colorType(name: "gray180")
    ///Hex value: #000000 Black
    static let gray200: GlassColor = GlassColor.colorType(name: "gray200")
}

public extension GlassColor {
    ///White color (same as gray00)
    static let white: GlassColor = GlassColor.gray00
    ///Black color (same as gray200)
    static let black: GlassColor = GlassColor.gray200
}

public extension GlassColor {
    static let blues: [GlassColor] = [
        .blue05,
        .blue10,
        .blue20,
        .blue30,
        .blue40,
        .blue50,
        .blue60,
        .blue70,
        .blue80,
        .blue90,
        .blue100,
        .blue110,
        .blue120,
        .blue130,
        .blue140,
        .blue150,
        .blue160,
        .blue170,
        .blue180
    ]

    static let reds: [GlassColor] = [
        .red05,
        .red10,
        .red20,
        .red30,
        .red40,
        .red50,
        .red60,
        .red70,
        .red80,
        .red90,
        .red100,
        .red110,
        .red120,
        .red130,
        .red140,
        .red150,
        .red160,
        .red170,
        .red180
    ]

    static let pinks: [GlassColor] = [
        .pink05,
        .pink10,
        .pink20,
        .pink30,
        .pink40,
        .pink50,
        .pink60,
        .pink70,
        .pink80,
        .pink90,
        .pink100,
        .pink110,
        .pink120,
        .pink130,
        .pink140,
        .pink150,
        .pink160,
        .pink170,
        .pink180
    ]

    static let oranges: [GlassColor] = [
        .orange05,
        .orange10,
        .orange20,
        .orange30,
        .orange40,
        .orange50,
        .orange60,
        .orange70,
        .orange80,
        .orange90,
        .orange100,
        .orange110,
        .orange120,
        .orange130,
        .orange140,
        .orange150,
        .orange160,
        .orange170,
        .orange180
    ]

    static let sparks: [GlassColor] = [
        .spark05,
        .spark10,
        .spark20,
        .spark30,
        .spark40,
        .spark50,
        .spark60,
        .spark70,
        .spark80,
        .spark90,
        .spark100,
        .spark110,
        .spark120,
        .spark130,
        .spark140,
        .spark150,
        .spark160,
        .spark170,
        .spark180
    ]

    static let yellows: [GlassColor] = [
        .yellow05,
        .yellow10,
        .yellow20,
        .yellow30,
        .yellow40,
        .yellow50,
        .yellow60,
        .yellow70,
        .yellow80,
        .yellow90,
        .yellow100,
        .yellow110,
        .yellow120,
        .yellow130,
        .yellow140,
        .yellow150,
        .yellow160,
        .yellow170,
        .yellow180
    ]

    static let purples: [GlassColor] = [
        .purple05,
        .purple10,
        .purple20,
        .purple30,
        .purple40,
        .purple50,
        .purple60,
        .purple70,
        .purple80,
        .purple90,
        .purple100,
        .purple110,
        .purple120,
        .purple130,
        .purple140,
        .purple150,
        .purple160,
        .purple170,
        .purple180
    ]

    static let greens: [GlassColor] = [
        .green05,
        .green10,
        .green20,
        .green30,
        .green40,
        .green50,
        .green60,
        .green70,
        .green80,
        .green90,
        .green100,
        .green110,
        .green120,
        .green130,
        .green140,
        .green150,
        .green160,
        .green170,
        .green180
    ]

    static let grays: [GlassColor] = [
        .clear,
        .gray00,
        .gray05,
        .gray10,
        .gray20,
        .gray30,
        .gray40,
        .gray50,
        .gray60,
        .gray70,
        .gray80,
        .gray90,
        .gray100,
        .gray110,
        .gray120,
        .gray130,
        .gray140,
        .gray150,
        .gray160,
        .gray170,
        .gray180,
        .gray200
    ]

    static let allColors: [GlassColor] = [
        blues,
        reds,
        pinks,
        oranges,
        sparks,
        yellows,
        purples,
        greens,
        grays
        ].reduce([], +)
}

public extension UIColor {
    convenience init(hex: String) {
        var hexBuffer = hex
        if hex.hasPrefix("#") && hex.count > 1 {
            hexBuffer = hex[1..<hex.count]
        }
        var componentLength: Int = 0
        if hexBuffer.count == 3 {
            componentLength = 1
        } else if hexBuffer.count == 6 || hexBuffer.count == 8 {
            componentLength = 2
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            return

        }
        var isValid: Bool = true
        var components = [CGFloat]()
        for index in 0..<4 {
            if index >= (hexBuffer.count / componentLength) {
                continue
            }
            var component: String =
                hexBuffer[componentLength * index..<(componentLength * index + componentLength)]
            if componentLength == 1 {
                component = component.appending(component)
            }
            let scanner: Scanner = Scanner(string: component)
            var value: UInt64 = 0
            let foundValue = scanner.scanHexInt64(&value)
            isValid = isValid && foundValue
            components.append(CGFloat(value) / 255.0)
        }

        guard isValid else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }

        self.init(red: components[0],
                  green: components[1],
                  blue: components[2],
                  alpha: components.count == 4 ? components[3] : 1.0)
    }
}

private extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
