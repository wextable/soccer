//
//  GlassPII.swift
//  GlassUI
//
//  Created by Jordan Perry on 10/7/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

/// `GlassPII` defines an object that can contain PII.
@objc
public protocol GlassPII: AnyObject {
    /// Whether or not the view contains PII.
    var containsPII: Bool { get set }

    /// Obfuscate the personally identifiable information, if present.
    @objc
    func obfuscatePII()

    /// Deobfuscate the personally identifiable information, if present.
    @objc
    func deobfuscatePII()
}

public protocol GlassPIINotificationPoster {
    func post(name aName: NSNotification.Name, object anObject: Any?)
}

public protocol GlassPIINotificationObserver {
    func addObserver(_ observer: Any,
                     selector aSelector: Selector,
                     name aName: NSNotification.Name?,
                     object anObject: Any?)
}

public extension GlassPIINotificationPoster {
    func postObfuscationNotification() {
        post(name: .obfuscationNotification, object: nil)
    }

    func postDeobfuscationNotification() {
        post(name: .deobfuscationNotification, object: nil)
    }
}

extension NotificationCenter: GlassPIINotificationPoster, GlassPIINotificationObserver {}

extension Notification.Name {
    static let obfuscationNotification = Notification.Name("GlassPII.obfuscationNotification")
    static let deobfuscationNotification = Notification.Name("GlassPII.deobfuscationNotification")
}

extension GlassPII {
    func setupNotificationObservers(observer: GlassPIINotificationObserver = NotificationCenter.default) {
        observer.addObserver(self,
                             selector: #selector(obfuscatePII),
                             name: .obfuscationNotification,
                             object: nil)

        observer.addObserver(self,
                             selector: #selector(deobfuscatePII),
                             name: .deobfuscationNotification,
                             object: nil)
    }
}
