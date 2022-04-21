//
//  Accessible.swift
//
//  Created by Tres Spicher on 7/20/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// MARK: Protocol

/// The `Accessible` protocol allows automatic assignment of accessibility identifiers to any
/// stored `UIView` properties. This is also a good place to put any future enhancements to accessibility
/// that require standardization across `UIViewController`s and `UIView`s
public protocol Accessible: AnyObject {
    /// Assigns every UIView child of this UIView instance a standardized accessibilityIdentifier (non-recursive).
    /// Default implementation assigns identifiers of the format:
    /// `ClassName.fieldName`
    func assignAccessibilityIdentifiers()
}

// MARK: Default implementation
extension Accessible {
    public func assignAccessibilityIdentifiers() {
        #if DEBUG
        assignDefaultIdentifiers()
        #endif
    }

    func assignDefaultIdentifiers() {
        #if DEBUG
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            mirror?.children.forEach {
                guard let child = $0.value as? UIView, let childLabel = $0.label,
                      child.accessibilityIdentifier == nil else {
                    return
                }
                assignDefaultIdentifier(to: child, label: childLabel)
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        #endif
    }

    func assignDefaultIdentifier(to child: UIAccessibilityIdentification, label: String) {
        #if DEBUG
        child.accessibilityIdentifier = "\(type(of: self)).\(label)"
        #endif
    }
}

// MARK: Customized identifiers

/// `AccessibilityID` allows custom assignment of AccessibilityIDs, overriding the default behavior of `Accessible`
///
/// ### Usage
/// ```swift
/// @AccessibilityID("MyCustomID") var view = UIView()
/// ```
@propertyWrapper struct AccessibilityID<Value: UIAccessibilityIdentification> {
    private var id: String
    private var value: Value

    init(wrappedValue value: Value, _ id: String) {
        self.value = value
        self.id = id
        self.value.accessibilityIdentifier = id
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            value.accessibilityIdentifier = id
        }
    }
}
