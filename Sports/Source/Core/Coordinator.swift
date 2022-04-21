//
//  Coordinator.swift
//  Sports
//
//  Created by Wesley St. John on 12/27/21.
//

import UIKit

/// The delegate to be used for the coordinator when dealing with children
public protocol CoordinatorChildDelegate: AnyObject {
    /// The coordinator did add a child coordinator.
    func coordinatorDidAdd<T, U>(_ coordinator: Coordinator<T>, child: Coordinator<U>)

    /// The coordinator did remove a child coordinator
    func coordinatorDidRemove<T, U>(_ coordinator: Coordinator<T>, child: Coordinator<U>)
}

/// The base coordinator class.
///
/// # Features:
/// - Automatic cleanup
/// - Return a `CoordinationResult` via its finish block.
open class Coordinator<CoordinationResult>: UIResponder {
    public weak var childDelegate: CoordinatorChildDelegate?

    /// Start the activity of the coordinator
    open func start() {

    }

    /// Function to call when you are finished
    /// subclassers must call super!
    open func finish(_ result: CoordinationResult) {
        onFinish?(result)
        cleanupFromParentBlock?()
    }

    /// The block performed when the coordinator has finished its flow
    public var onFinish: ((CoordinationResult) -> Void)?

    // MARK: - Helpers

    private let identifier = UUID()
    private var children = [UUID: Any]()

    private var cleanupFromParentBlock: (() -> Void)?

    public func addChild<T>(coordinator: Coordinator<T>) {
        coordinator.cleanupFromParentBlock = { [weak self, weak coordinator] in
            self?.removeChild(coordinator: coordinator)
        }
        children[coordinator.identifier] = coordinator
        childDelegate?.coordinatorDidAdd(self, child: coordinator)
    }

    private func removeChild<T>(coordinator: Coordinator<T>?) {
        guard let coordinator = coordinator else {
            return
        }

        children.removeValue(forKey: coordinator.identifier)
        childDelegate?.coordinatorDidRemove(self, child: coordinator)
    }
}
