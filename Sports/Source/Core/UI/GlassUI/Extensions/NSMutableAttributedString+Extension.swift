//
//  NSMutableAttributedString+Extension.swift
//  GlassUI
//
//  Created by Timothy Sears on 5/10/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// MARK: - NSMutableAttributedString+Extension

public extension NSMutableAttributedString {
    /// Creates a mutable attributed string from an HTML fragment.
    ///
    /// ```
    /// let html = "<b>BOLD</b>"
    /// let attr = NSMutableAttributedString.convertHtmlToAttributedString(html.data(using: .utf8)!)
    /// ```
    static func convertHtmlToAttributedString(_ data: Data) -> NSMutableAttributedString? {
        return try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
    }

    /// Sets the font face of the string but leaves any specified fonts of internal strings as-is.
    func settingFontFace(font: UIFont) {
        beginEditing()

        // Popular answer for how to enumerate through an attributed string and preserve custom HTML styling attributes
        // with a custom font.
        // https://stackoverflow.com/a/47320125/496351
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            if let fontValue = value as? UIFont,
               let newFontDescriptor = fontValue.fontDescriptor
                .withFamily(font.familyName)
                .withSymbolicTraits(fontValue.fontDescriptor.symbolicTraits) {

                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
            }
        }
        endEditing()
    }

    /// Trim any characters in the provided set from the start of the string.
    func trimmedStart(_ charset: CharacterSet = .whitespacesAndNewlines) -> NSMutableAttributedString {
        guard let nonTrimRange = string.rangeOfCharacter(from: charset.inverted) else {
            return .init(string: "") // No non-trimmable characters
        }

        let lowerBoundOffset = nonTrimRange.lowerBound.utf16Offset(in: string)
        let trimmedStr = attributedSubstring(from: NSRange(location: lowerBoundOffset,
                                                           length: length - lowerBoundOffset))
        return .init(attributedString: trimmedStr)
    }

    /// Trim any characters in the provided set from the end of the string.
    func trimmedEnd(_ charset: CharacterSet = .whitespacesAndNewlines) -> NSMutableAttributedString {
        guard let nonTrimRange = string.rangeOfCharacter(from: charset.inverted, options: .backwards) else {
            return .init(string: "") // No non-trimmable characters
        }

        let upperBoundOffset = nonTrimRange.upperBound.utf16Offset(in: string)
        let trimmedStr = attributedSubstring(from: NSRange(location: 0, length: upperBoundOffset))
        return .init(attributedString: trimmedStr)
    }

    /// Trim any characters in the provided set from the start and end of the string.
    func trimmedAttributedString(_ charset: CharacterSet = .whitespacesAndNewlines) -> NSMutableAttributedString {
        trimmedStart(charset).trimmedEnd(charset)
    }
}
