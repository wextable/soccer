//
//  StandardModalContainerViewController.swift
//  GlassUI
//
//  Created by Amisha Chordia on 12/05/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

/// A simple container view controller that allows BottomSheets to be presented as modal view controllers with the
/// standard UIModalPresentationStyle. The `triggerDismiss` in `BottomSheetableActionDelegate` is respected.
class StandardModalContainerViewController: BaseViewController {

    private let bottomSheet: BottomSheetable

    init(bottomSheet: BottomSheetable) {
        self.bottomSheet = bottomSheet
        super.init(nibName: nil, bundle: nil)
        setupBottomSheetVC()
    }

    private func setupBottomSheetVC() {
        addChild(bottomSheet)
        view.addAutoLayoutSubview(bottomSheet.view)
        NSLayoutConstraint.activate(bottomSheet.view.constraints(pinningTo: view))
        bottomSheet.didMove(toParent: self)
        bottomSheet.bottomSheetableActionDelegate = self
    }
}

extension StandardModalContainerViewController: BottomSheetableActionDelegate {
    func triggerDismiss(_ sender: BottomSheetable) {
        bottomSheet.shouldDismiss { [weak self] allowed in
            guard let self = self else { return }
            // Dismiss if allowed
            if allowed {
                self.view.endEditing(true)
                self.dismiss(animated: true) {
                    self.bottomSheet.dismissCompletion()
                }
            }
        }
    }

    func triggerViewUpdate(_ sender: BottomSheetable) {
        // no-op
    }

    func updateTier(_ sender: BottomSheetable, change: BottomSheetChange) -> BottomSheetTier {
        sender.startingTier
    }
}
