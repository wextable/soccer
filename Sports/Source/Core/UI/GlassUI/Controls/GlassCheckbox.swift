//
//  GlassCheckbox.swift
//  
//
//  Created by Rupani, Sohil (US - Seattle) on 1/29/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import UIKit

/// Checkbox with 3 states - selected, unselected and disabled
/// # Reference
/// - [Zeplin Stickersheet](https://zpl.io/VQy6EdA )
///
/// # Example
/// ```
///    let checkBox = GlassCheckbox()
///    checkBox.translatesAutoresizingMaskIntoConstraints = false
///    checkBox.isSelected = true
/// ```

public class GlassCheckbox: UIButton {

    private lazy var checkbox: Checkbox = {
        let checkbox = Checkbox(frame: self.frame)
        checkbox.isUserInteractionEnabled = false
        return checkbox
    }()

    private lazy var hapticEngine: GlassHapticEngine = {
        let engine = GlassHapticEngine()
        engine.view = self
        return engine
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    /// A block which will be invoked after taps (`touchUpInside`)
    ///
    /// As always with blocks be careful not to create retention cycles.
    public var onTap: GlassButtonTapHandler?

    private func postInit() {
        setupView()
        setupCheckbox()
        setupConstraints()
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        registerTapHandler()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = GlassColor.gray00.uiColor
        clipsToBounds = true
        roundCorners(corners: [.bottomRight], radius: 5.0)
    }

    private func setupCheckbox() {
        addAutoLayoutSubview(checkbox)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: GlassSpacing.small + GlassSpacing.xxSmall),
            widthAnchor.constraint(equalToConstant: GlassSpacing.small + GlassSpacing.xxSmall),
            checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            checkbox.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }

    @objc func toggle() {
        isSelected = !isSelected
        checkbox.isSelected = isSelected
        hapticEngine.start(.medium)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.higAppropriateTapRect.contains(point)
    }
}

private class Checkbox: UIView {
    private struct Constants {
        static let borderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 2.0
    }
    private var checkmarkView: UIImageView!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    public var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? GlassColor.gray200.uiColor : GlassColor.gray00.uiColor
        }
    }

    private func postInit() {
        setupView()
        setupCheckmarkView()
        setupConstraints()
    }

    private func setupView() {
        layer.borderColor = GlassColor.gray200.uiColor.cgColor
        backgroundColor = isSelected ? GlassColor.gray200.uiColor : GlassColor.gray00.uiColor
        layer.borderWidth = Constants.borderWidth
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
    }
    private func setupCheckmarkView() {
        checkmarkView = UIImageView()
        checkmarkView.image = GlassIcon.check.image.imageWithColor(color: GlassColor.gray00.uiColor)
        addAutoLayoutSubview(checkmarkView)
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: GlassSpacing.small),
            widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            checkmarkView.constraints(pinningTo: self)
        ])
    }
}

public extension CGRect {
    var higAppropriateTapRect: CGRect {
        let higSize = CGSize(width: 44, height: 44)
        let widthDelta = max(higSize.width - width, 0)
        let heightDelta = max(higSize.height - height, 0)

        return self.inset(by: .init(top: -heightDelta / 2.0,
                                    left: -widthDelta / 2.0,
                                    bottom: -heightDelta / 2.0,
                                    right: -widthDelta / 2.0))
    }
}

#if DEBUG
extension GlassCheckbox {
    struct TestHooks {
        let target: GlassCheckbox
        var checkBoxBackgroundColor: UIColor? {
            return target.checkbox.backgroundColor
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
