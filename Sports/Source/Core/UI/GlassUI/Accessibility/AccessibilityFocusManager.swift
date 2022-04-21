//
//  AccessibilityFocusManager.swift
//  WalmartIOSShared
//
//  Created by Boris Mezhibovskiy on 5/8/19.
//  Copyright © 2019 WalmartLabs. All rights reserved.
//
import UIKit

public class AccessibilityFocusManager {

    private static var accessibilityIds: [String] = []

    private static var accessibilitySettings: AccessibilitySettings.Type = UIAccessibility.self

    static func updateAccessibilitySettings(_ accessibilitySettings: AccessibilitySettings.Type) {
        self.accessibilitySettings = accessibilitySettings
    }

    static func resetAccessibilitySettings() {
        accessibilitySettings = UIAccessibility.self
    }

    /// Sets the voiceover cursor to one of the accessibility ids that was previously stored, if found
    /// Ideally called in viewDidAppear of the view controller that has presented a detail view.
    public static func restoreAccessibilityFocus() {
        guard accessibilitySettings.isVoiceOverRunning
            else { return }

        guard let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.windows.first else { return }
        if let rootView = window.rootViewController?.view,
            let focusTarget = findFocusTarget(in: rootView) {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: focusTarget)
        }
    }

    /// Saves an accessibility id so that it can be focused on later
    /// Ideally called right before navigating to a detail view, with the accessibilityId of the button
    public static func saveAccessibilityFocus(of accessibilityId: String) {
        guard accessibilitySettings.isVoiceOverRunning
            else { return }

        accessibilityIds.append(accessibilityId)
    }

    /// Recursively traverses the view heirarchy to find a view with an accessibility id that's in our list
    /// If found, it removes the accessibility id from the list and returns the view.
    private static func findFocusTarget(in view: UIView) -> UIView? {
        if let viewAccessibilityId = view.accessibilityIdentifier,
            let index = accessibilityIds.firstIndex(of: viewAccessibilityId) {
            accessibilityIds.remove(at: index)
            return view
        }
        for subview in view.subviews {
            if let foundFocusTarget = findFocusTarget(in: subview) {
                return foundFocusTarget
            }
        }
        return nil
    }
}

protocol AccessibilitySettings {
    static var isVoiceOverRunning: Bool { get }
}

extension UIAccessibility: AccessibilitySettings {}

#if DEBUG
extension AccessibilityFocusManager {
    public static var accessibilityIdsHook: [String] {
        accessibilityIds
    }

    public static func findFocusTargetHook(in view: UIView) -> UIView? {
        return findFocusTarget(in: view)
    }
}
#endif
