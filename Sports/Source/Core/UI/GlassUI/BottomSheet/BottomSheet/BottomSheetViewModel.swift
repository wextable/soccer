//
//  BottomSheetViewModel.swift
//  GlassUI
//
//  Created by Stratton Aguilar on 5/5/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

private let transitionThreshold: CGFloat = 24

class BottomSheetViewModel {

    private var bottomSheetConfig: BottomSheetable
    var backgroundColor: UIColor { return bottomSheetConfig.backgroundColor }
    var isExpandable: Bool { return bottomSheetConfig.isExpandable }
    var view: UIView { return bottomSheetConfig.contentView }
    var isNav: Bool { return bottomSheetConfig is UINavigationController }
    var verticalScrollViews: [UIScrollView] { return bottomSheetConfig.verticalScrollViews }
    var minimalHeight: CGFloat { return bottomSheetConfig.minimalHeight }
    var maxBottomSheetHeight: CGFloat { return bottomSheetConfig.maxBottomSheetHeight }
    var shouldHideGrabber: Bool { bottomSheetConfig.shouldHideGrabber }
    private(set) var currentTier: BottomSheetTier
    var expandedHeight: CGFloat? { return bottomSheetConfig.expandedHeight }
    var getHeightForCurrentTier: CGFloat { return bottomSheetConfig.getHeight(forTier: currentTier) }
    var getExpansionDifference: CGFloat { return bottomSheetConfig.getExpansionDifference(forTier: currentTier) }
    var dismissCompletion: (() -> Void)? { return bottomSheetConfig.dismissCompletion }
    var shouldDismiss: (@escaping (Bool) -> Void) -> Void? { return bottomSheetConfig.shouldDismiss }
    var shouldIgnoreTabBar: Bool { bottomSheetConfig.shouldIgnoreTabBar }

    init(bottomSheetConfig: BottomSheetable) {
        self.bottomSheetConfig = bottomSheetConfig
        self.currentTier = bottomSheetConfig.getStartingTierWithValdation()
    }

    func updateTierState(currentHeight: CGFloat) {
        guard isExpandable else { return }
        let bottomLimit = bottomSheetConfig.getHeight(forTier: currentTier)
        if currentHeight > bottomLimit + transitionThreshold {
            updateTier(change: .expand)
        } else if currentHeight < bottomLimit - transitionThreshold {
            updateTier(change: .contract)
        }
    }

    @discardableResult
    func updateTier(change: Change) -> (Bool, BottomSheetTier) {
        let newTier: BottomSheetTier
        switch change {
        case .expand:
            newTier = bottomSheetConfig.getNextTier(forTier: currentTier)
        case .contract:
            newTier = bottomSheetConfig.getPreviousTier(forTier: currentTier)
        }

        var isChange: Bool = false

        if newTier != currentTier {
            currentTier = newTier
            updateSubviewVericalScroll()
            isChange = true
        }

        return (isChange, currentTier)
    }

    func didPassDismissalThreshold(forContentSize contentHeight: CGFloat, yDifference: CGFloat) -> Bool {
        switch bottomSheetConfig.tiersType {
        case .oneHeight, .oneTierAutomatic:
            let currentContent = contentHeight - yDifference
            return currentContent < contentHeight * 3/4
        case .threeHeights, .twoHeights:
            let currentContent = getHeightForCurrentTier - yDifference
            return currentContent < minimalHeight * 3/4
        }
    }

    func getScrollToDismissalPercentage(forYDifference yDifference: CGFloat, defaultSize: CGFloat) -> CGFloat? {
        let height = bottomSheetConfig.tiersType != BottomSheetTierType.oneTierAutomatic ? minimalHeight : defaultSize
        guard height > 0 else { return nil }
        guard currentTier == .minimum && yDifference > 0 && yDifference < height else { return nil }
        return yDifference / height
    }

    func updateSubviewVericalScroll() {
        let isEnabled = bottomSheetConfig.shouldContentScrollViewBeEnabled(forTier: currentTier)
        for scrollview in bottomSheetConfig.verticalScrollViews {
            scrollview.isScrollEnabled = isEnabled
            scrollview.showsVerticalScrollIndicator = isEnabled
        }
    }

    func cleanUpChildViewController() {
        bottomSheetConfig.unembedFromParent()
    }

    enum Change {
        case expand
        case contract
    }
}

extension BottomSheetViewModel.Change {
    init(change: BottomSheetChange) {
        switch change {
        case .contract:
            self = .contract
        case .expand:
            self = .expand
        }
    }
}
