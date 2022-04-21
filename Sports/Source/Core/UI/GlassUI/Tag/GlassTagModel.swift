//
//  GlassTagModel.swift
//  GlassUI
//
//  Created by Amisha Chordia on 26/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

/// Model for updating the contents and design of the Glasstag component
public struct GlassTagModel {
    public enum TagShade {
        case red
        case spark
        case green
        case blue
        case purple
        case gray

        var primaryColor: GlassColor {
            switch self {
            case .red:
                return .red100
            case .spark:
                return .spark100
            case .green:
                return .green100
            case .blue:
                return .blue160
            case .purple:
                return .purple100
            case .gray:
                return .gray100
            }
        }

        var tertiaryColor: GlassColor {
            switch self {
            case .red:
                return .red10
            case .spark:
                return .spark10
            case .green:
                return .green10
            case .blue:
                return .blue10
            case .purple:
                return .purple10
            case .gray:
                return .gray10
            }
        }

        var secondaryColor: GlassColor {
            switch self {
            case .red:
                return .red130
            case .spark:
                return GlassColor(hex: "#995213")
            case .green:
                return .green130
            case .blue:
                return .blue130
            case .purple:
                return .purple130
            case .gray:
                return .gray130
            }
        }
    }

    public enum TagType {
        case primary(shade: TagShade)
        case secondary(shade: TagShade)
        case tertiary(shade: TagShade)

        var contentForegroundColor: GlassColor {
            switch self {
            case .primary(let shade):
                switch shade {
                case .spark:
                    return .black
                default:
                    return .white
                }
            case .secondary(let shade):
                return shade.secondaryColor
            case .tertiary(let shade):
                return shade.secondaryColor
            }
        }

        var borderColor: GlassColor {
            switch self {
            case .primary, .tertiary:
                return .clear
            case .secondary(let shade):
                return shade.secondaryColor
            }
        }

        var backgroundColor: GlassColor {
            switch self {
            case .primary(let shade):
                return shade.primaryColor
            case .secondary:
                return .white
            case .tertiary(let shade):
                return shade.tertiaryColor
            }
        }
    }

    let tagType: TagType
    let icon: GlassIcon?
    public var text: String

    public init(tagType: TagType, icon: GlassIcon? = nil, text: String) {
        self.tagType = tagType
        self.icon = icon
        self.text = text
    }
}
