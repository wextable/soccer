//
//  BottomSheetable.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/5/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

/// The parameters adopted by an object allow for presenting a view inside of a BottomSheet
///
/// Only three parameters are required
/// # Example
/// ```swift
/// weak var bottomSheetableActionDelegate: BottomSheetableActionDelegate?
/// var contentView: UIView { return view }
/// var tiersType: BottomSheetTierType {  return BottomSheetTierType.threeHeights(100, 300, 300) }
/// ```
/// # Discussion
/// ``bottomSheetableActionDelegate`` allows the adopting object to trigger events on the container view
/// **Do not override this property** only use it's methods.  Should always be weak
///
/// ``contentView`` is the entire view that will be rendered inside of the BottomSheet View
///
/// ``tiersType`` specifics the number and size of places the view can 'rest' in place make sure to test on
/// phone do not have the screen edge to edge to make sure extended content is shown.  The sum of the emun
/// parameters specifiy the minimum height for the contentView
/// Additional parameters and methods
/// # Additional Parameters with Defaults
/// ```swift
/// var maxBottomSheetHeight: CGFloat = BottomSheetDefaults().maxHeight(isEmbeddedInNav: isEmbeddedInNav)
/// var startingTier: BottomSheetTier { return .minimum }
/// var verticalScrollViews: [UIScrollView] = []
/// var backgroundColor: UIColor { return .white }
/// var shouldHideGrabber: Bool { return false }
/// var isKeyboardObserver: Bool { return true }
/// func dismissCompletion() { }
/// func shouldDismiss(completion: @escaping (Bool) -> Void) { completion(true) }
/// ```
/// ``maxBottomSheetHeight`` is the maximum height the view can expand to.
/// # Discussion
/// ``verticalScrollViews`` needs to be set when the content view has a vertical scroll view
/// this exposes what scrollviews pan actions need to be intercepted while scrolling between Tiers
public protocol BottomSheetable: UIViewController {
    // This object should always be weak
    var bottomSheetableActionDelegate: BottomSheetableActionDelegate? { get set }
    var maxBottomSheetHeight: CGFloat { get }

    var contentView: UIView { get }
    var tiersType: BottomSheetTierType { get }

    var startingTier: BottomSheetTier { get }
    var verticalScrollViews: [UIScrollView] { get }
    var backgroundColor: UIColor { get }
    var shouldHideGrabber: Bool { get }
    var isKeyboardObserver: Bool { get }
    func dismissCompletion()
    func shouldDismiss(completion: @escaping (Bool) -> Void)
    var isDismissable: Bool { get }
    var shouldIgnoreTabBar: Bool { get }
    var useSafeArea: Bool { get }
}

public extension BottomSheetable {
    var maxBottomSheetHeight: CGFloat {
        return BottomSheetDefaults().maxHeight(isEmbeddedInNav: isEmbeddedInNav)
    }
    var verticalScrollViews: [UIScrollView] { return [] }
    var backgroundColor: UIColor { return .white }
    var startingTier: BottomSheetTier { return .minimum }
    var shouldHideGrabber: Bool { return false }
    var isKeyboardObserver: Bool { return true }
    var isDismissable: Bool { return true }
    func dismissCompletion() {}
    func shouldDismiss(completion: @escaping (Bool) -> Void) { completion(true) }

    var shouldIgnoreTabBar: Bool { return false }
    var isExpandable: Bool { return tiersType.isExpandable }

    var minimalHeight: CGFloat { return tiersType.minimumHeight ?? expandedHeight ?? 0 }
    var expandedHeight: CGFloat? {
        guard let expandedHeight = tiersType.expandedHeight else { return nil }
        return expandedHeight <= maxBottomSheetHeight ? expandedHeight : maxBottomSheetHeight
    }

    internal func getExpansionDifference(forTier tier: BottomSheetTier) -> CGFloat {
        guard isExpandable, let defaultExpandedHeight = expandedHeight else { return 0 }
        let tierHeight = getHeight(forTier: tier)
        return defaultExpandedHeight - tierHeight
    }

    internal func getHeight(forTier tier: BottomSheetTier) -> CGFloat {
        let height = tiersType.getHeight(forTier: tier)
        guard height > 0 else { return 0 }
        return height > maxBottomSheetHeight ? maxBottomSheetHeight : height
    }

    internal func getNextTier(forTier tier: BottomSheetTier) -> BottomSheetTier {
        switch tiersType {
        case .oneTierAutomatic, .oneHeight: return .minimum
        case .twoHeights: return .detail
        case .threeHeights: return tier.next
        }
    }

    internal func getPreviousTier(forTier tier: BottomSheetTier) -> BottomSheetTier {
        switch tiersType {
        case .oneTierAutomatic, .oneHeight, .twoHeights: return .minimum
        case .threeHeights: return tier.previous
        }
    }

    internal func shouldContentScrollViewBeEnabled(forTier tier: BottomSheetTier) -> Bool {
        switch tiersType {
        case .oneTierAutomatic, .oneHeight: return true
        case .twoHeights:
            switch tier {
            case .detail: return true
            default: return false
            }
        case .threeHeights:
            switch tier {
            case .minimum, .detail: return false
            case .full: return true
            }
        }
    }

    internal func getStartingTierWithValdation() -> BottomSheetTier {
        switch tiersType {
        case .oneTierAutomatic, .oneHeight: return .minimum
        case .twoHeights:
            if startingTier != .full {
                return startingTier
            } else {
                return .minimum
            }
        case .threeHeights: return startingTier

        }
    }

    var useSafeArea: Bool {
        return false
    }
}
/// This enum is a convience around BottomSheet Tiers
///
///  The first section shown is the `minimum` tier
///
///  The second section shown is the `detail` tier
///
///  The third section shown is the `full` tier
///
/// ```swift
/// case minimum = 0
/// case detail = 1
/// case full = 2
/// ```
///
public enum BottomSheetTier: Int {
    case minimum = 0
    case detail = 1
    case full = 2

    var next: BottomSheetTier {
        guard let nextTier = BottomSheetTier(rawValue: self.rawValue + 1) else { return self }
        return nextTier
    }

    var previous: BottomSheetTier {
        guard let previousTier = BottomSheetTier(rawValue: self.rawValue - 1) else { return self }
        return previousTier
    }
}

/// This enum defines the Tiers for the Bottom Sheet.
/// Each Section height defines a snapping point for the BottomSheetView
///
/// # Example
/// ```swift
/// var tiersType: BottomSheetTierType {  return BottomSheetTierType.threeHeights(60, 300, 200) }
/// ```
/// Above would define the top tier shown as 60 points, the middle tier as 300 points and the bottom tier as 200 points.
/// The sum of these heights deterines the minimum height for the entire view.
/// The minimum content height in the example would be 560.
///
/// When using oneTierAutomatic make sure to have constraints set to the top and bottom of your view.
/// The content height will be determined by the height of the view's constraints
/// ```swift
/// case threeHeights(CGFloat, CGFloat, CGFloat)
/// case twoHeights(CGFloat, CGFloat)
/// case oneHeight(CGFloat)
/// case oneTierAutomatic
/// ```
///
public enum BottomSheetTierType: Equatable {
    case threeHeights(CGFloat, CGFloat, CGFloat)
    case twoHeights(CGFloat, CGFloat)
    case oneHeight(CGFloat)
    case oneTierAutomatic

    internal var numberOfTiers: Int {
        switch self {
        case .oneTierAutomatic: return 1
        default: return allTierHeights.count
        }
    }

    private var allTierHeights: [CGFloat] {
        switch self {
        case .threeHeights(let one, let two, let three): return [one, one + two, one + two + three]
        case .twoHeights(let one, let two): return [one, one + two]
        case .oneHeight(let one): return [one]
        case .oneTierAutomatic: return []
        }
    }

    internal var expandedHeight: CGFloat? { return allTierHeights.last }
    internal var minimumHeight: CGFloat? { return allTierHeights.first }

    internal var isExpandable: Bool {
        switch self {
        case .threeHeights, .twoHeights: return true
        default: return false
        }
    }

    internal func getHeight(forTier tier: BottomSheetTier) -> CGFloat {
        let lowerLimit = tier.rawValue < allTierHeights.count ? allTierHeights[tier.rawValue] : 0
        return lowerLimit
    }
}
