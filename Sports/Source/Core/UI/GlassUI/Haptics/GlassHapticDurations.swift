//
//  GlassHapticDurations.swift
//  GlassUI
//
//  Created by Joshua Mann on 12/17/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import CoreHaptics
import Foundation
import UIKit

public enum GlassHaptics {
    case soft
    case selection
    case medium
    case rigid

    func perform() {
        switch self {
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }
}

public class GlassHapticEngine {
    private var engine: CHHapticEngine?
    public var view: UIView?
    /*internal*/ var hapticsEnabled = true

    public init() {
        do {
            engine = try? CHHapticEngine()
            try engine?.start()
        } catch { }
    }

    public func start(_ haptic: GlassHaptics) {
        if hapticsEnabled {
            haptic.perform()
        }
    }
}
