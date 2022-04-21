//
//  GlassAccessoryToolbar.swift
//  GlassUI
//
//  Created by Boris Mezhibovskiy on 1/30/18.
//  Copyright © 2018 WalmartLabs. All rights reserved.
//

import UIKit

/// AccessoryToolBar BarbuttonItem Types, Do not use this directly
public enum GlassAccessoryToolbarButton: Int {
    case done
    case prev
    case next
    case cancel
}

/// Accessory toolbar used over keyboard for switching between textfields with controls like ❮, ❯, Done and Cancel
@objc public class GlassAccessoryToolbar: UIToolbar {
    private(set) var cancelButton: UIBarButtonItem?
    private(set) var doneButton: UIBarButtonItem?
    private(set) var prevButton: UIBarButtonItem?
    private(set) var nextButton: UIBarButtonItem?

    private var doneAction: (() -> Void)?
    private var prevAction: (() -> Void)?
    private var nextAction: (() -> Void)?
    private var cancelAction: (() -> Void)?

    /**
    ❮   ❯ ____________________ Done

     Use this init to add a accessory toolbar to switch between consecutive textfields

     - Parameter doneAction: Completion action when Done button will be tapped
     - Parameter prevAction: Completion action when ❮ button will be tapped
     - Parameter nextAction: Completion action when ❯ button will be tapped

     ```
     textField.setCustomAccessoryToolbar(doneAction: {
        log("done clicked")
     }, prevAction: {
        log("prev clicked")
     }, nextAction: {
        log("next clicked")
     })
     ```
    */
    public init(doneAction: (() -> Void)?, prevAction: (() -> Void)?, nextAction: (() -> Void)?) {
        // UIToolbar needs to get default width and height to avoid constraints error.
        // Details on here https://jira.walmart.com/browse/OAF-2086
        super.init(frame: .init(x: 0, y: 0, width: 100, height: 44))
        self.doneAction = doneAction
        self.prevAction = prevAction
        self.nextAction = nextAction
        cancelAction = nil
        setupToolbar()
    }

    /**
    Cancel _____________________ Done

    Use this init to add accessory toolbar to pickers, single textfields, textviews
     where just done and cancel actions are required

    - Parameter doneAction: Completion action when Done button will be tapped
    - Parameter cancelAction: Completion action when Cancel button will be tapped

     ```
     textField.customAccessoryToolbar = GlassAccessoryToolbar(doneAction: {
        log("Done")
        self.endEditing(true)
     }, cancelAction: {
        log("Cancel")
        self.endEditing(true)
     })
     ```
    */
    public init(doneAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        // UIToolbar needs to get default width and height to avoid constraints error.
        // Details on here https://jira.walmart.com/browse/OAF-2086
        super.init(frame: .init(x: 0, y: 0, width: 100, height: 44))
        self.doneAction = doneAction
        self.cancelAction = cancelAction
        nextAction = nil
        prevAction = nil
        setupToolbar()
    }

    @available(*, unavailable)
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }

    @available(*, unavailable, message: "Create your views in code as BaseView subclasses please")
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupToolbar()
    }

    public func setEnabled(_ enabled: Bool, button: GlassAccessoryToolbarButton) {
        switch button {
        case .done:
            doneButton?.isEnabled = enabled
        case .prev:
            prevButton?.isEnabled = enabled
        case .next:
            nextButton?.isEnabled = enabled
        case .cancel:
            cancelButton?.isEnabled = enabled
        }
        updateAccessoryBarButtons()
    }

    @objc private func doDoneAction() {
        doneAction?()
    }

    @objc private func doPrevAction() {
       prevAction?()
    }

    @objc private func doNextAction() {
        nextAction?()
    }

    @objc private func doCancelAction() {
        cancelAction?()
    }

    private func setupToolbar() {
        sizeToFit()
        tintColor = GlassColor.blue160.uiColor
        barStyle = .default
        autoresizingMask = .flexibleWidth

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(GlassAccessoryToolbar.doDoneAction))

        if prevAction != nil || nextAction != nil {
            prevButton = UIBarButtonItem(title: "  ❮  ",
                                         style: .plain,
                                         target: self,
                                         action: #selector(GlassAccessoryToolbar.doPrevAction))
            nextButton = UIBarButtonItem(title: "  ❯  ",
                                         style: .plain,
                                         target: self,
                                         action: #selector(GlassAccessoryToolbar.doNextAction))
            prevButton?.isEnabled = false
            nextButton?.isEnabled = false
            items = [prevButton!, nextButton!, space, doneButton!]
        } else if cancelAction != nil {
            cancelButton = UIBarButtonItem(title: "Cancel",
                                           style: .plain,
                                           target: self,
                                           action: #selector(GlassAccessoryToolbar.doCancelAction))
            cancelButton?.isEnabled = true
            items = [cancelButton!, space, doneButton!]

        } else {
            items = [space, doneButton!]
        }
        updateAccessoryBarButtons()
    }

    private func updateAccessoryBarButtons() {
        let activeColorAttribute = [NSAttributedString.Key.foregroundColor:
                                        GlassColor.blue160.uiColor]

        doneButton?.setTitleTextAttributes(activeColorAttribute, for: .normal)
        prevButton?.setTitleTextAttributes(activeColorAttribute, for: .normal)
        nextButton?.setTitleTextAttributes(activeColorAttribute, for: .normal)
        cancelButton?.setTitleTextAttributes(activeColorAttribute, for: .normal)

        prevButton?.isAccessibilityElement = true
        prevButton?.accessibilityLabel = "Move to the previous field"
        nextButton?.isAccessibilityElement = true
        nextButton?.accessibilityLabel = "Move to the next field"
    }
}

#if DEBUG

extension GlassAccessoryToolbar {
    var testHooks: TestHooks {
        .init(target: self)
    }

    class TestHooks {
        let target: GlassAccessoryToolbar
        init(target: GlassAccessoryToolbar) {
            self.target = target
        }

        func doDoneAction() {
            target.doDoneAction()
        }

        func doCancelAction() {
            target.doCancelAction()
        }

        func doNextAction() {
            target.doNextAction()
        }

        func doPrevAction() {
            target.doPrevAction()
        }

    }
}

#endif
