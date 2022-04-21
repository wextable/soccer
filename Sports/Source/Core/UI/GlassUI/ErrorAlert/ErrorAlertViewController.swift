//
//  ErrorAlertViewController.swift
//  GlassUI
//
//  Created by Manoj Kumar Mahapatra on 7/22/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

public protocol AlertableError: Error {
    var alertTitle: String? { get }
    var alertMessage: String? { get }
    var alertActionTitle: String { get }
}

public class ErrorAlertViewController: BaseViewController {

    public struct Model {
        public var error: AlertableError
        public var maxDisplay: Int

        public init(error: AlertableError, maxDisplay: Int = 1) {
            self.error = error
            self.maxDisplay = maxDisplay
        }
    }

    private var currentDisplayCount = 0

    private let model: Model

    public init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        displayAlertIfNeeded()
    }

    private func displayAlertIfNeeded() {
        guard currentDisplayCount < model.maxDisplay, presentedViewController == nil else { return }
        currentDisplayCount += 1

        let alert = UIAlertController(
            title: model.error.alertTitle,
            message: model.error.alertMessage,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: model.error.alertActionTitle, style: .default))

        present(alert, animated: true)
    }

    public override func constructView() {
        super.constructView()

        view.backgroundColor = GlassColor.gray00.uiColor
    }
}

// MARK: - TestHooks
#if DEBUG
extension ErrorAlertViewController {
    var testHooks: TestHooks { TestHooks(target: self) }

    struct TestHooks {
        let target: ErrorAlertViewController

        var currentDisplayCount: Int { target.currentDisplayCount }
    }
}
#endif
