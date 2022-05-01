//
//  CheckboxView.swift
//  Sports
//
//  Created by Wesley St. John on 4/26/22.
//

import UIKit

/// Checkbox with 3 states - selected, unselected and disabled
///
/// # Example
/// ```
///    let checkBox = CardSelectionCheckbox()
///    checkBox.translatesAutoresizingMaskIntoConstraints = false
///    checkBox.isSelected = true
/// ```
class CheckboxView: UIButton {
    private var theme: Theme
    var checkmarkView: UIImageView!
    var size: CGFloat = 22.0

    init(_ theme: Theme = .dark, size: CGFloat = 22.0) {
        self.theme = theme
        self.size = size
        super.init(frame: .zero)
        postInit()
    }

    override init(frame: CGRect) {
        self.theme = .dark
        super.init(frame: frame)
        postInit()
    }

    required init?(coder aDecoder: NSCoder) {
        self.theme = .dark
        super.init(coder: aDecoder)
        postInit()
    }

    override var isSelected: Bool {
        didSet {
            applyTheme()
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            applyTheme()
        }
    }

    private func postInit() {
        checkmarkView = UIImageView()
        applyTheme()
        layer.borderWidth = 1.0
        layer.cornerRadius = 2.0
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        addAutoLayoutSubview(checkmarkView)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: size),
            widthAnchor.constraint(equalToConstant: size),
            checkmarkView.constraints(pinningTo: self)
        ])
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }

    private func applyTheme() {
        checkmarkView.isHidden = !isSelected
        let palette = activePalette
        checkmarkView.image = GlassIcon.check.image.imageWithColor(color: palette.checkmarkColor?.uiColor
                                                                   ?? .clear)
        layer.borderColor = palette.borderColor.uiColor.cgColor
        backgroundColor = palette.backgroundColor?.uiColor
    }

    @objc private func toggle() {
        isSelected = !isSelected
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.higAppropriateTapRect.contains(point)
    }
}

extension CheckboxView {
    struct Theme {
        fileprivate var selectedPalette: Palette
        fileprivate var unSelectedPalette: Palette
        fileprivate var disabledSelectedPalette: Palette
        fileprivate var disabledUnselectedPalette: Palette
    }

    fileprivate var activePalette: Theme.Palette {
        switch (isUserInteractionEnabled, isSelected) {
        case (true, true):
            return theme.selectedPalette
        case (true, false):
            return theme.unSelectedPalette
        case (false, true):
            return theme.disabledSelectedPalette
        case (false, false):
            return theme.disabledUnselectedPalette
        }
    }
}

private extension CheckboxView.Theme {
    struct Palette {
        var backgroundColor: GlassColor?
        var borderColor: GlassColor
        var checkmarkColor: GlassColor?
    }
}

extension CheckboxView.Theme {
    static let light: Self = .init(
        selectedPalette: .init(backgroundColor: .gray00, borderColor: .gray00, checkmarkColor: .gray200),
        unSelectedPalette: .init(backgroundColor: nil, borderColor: .gray00),
        disabledSelectedPalette: .init(backgroundColor: .gray50, borderColor: .gray50, checkmarkColor: .gray200),
        disabledUnselectedPalette: .init(backgroundColor: nil, borderColor: .gray50)
    )
    // TODO: Update disabled palettes when we receive feedback from design.
    static let dark: Self = .init(
        selectedPalette: .init(backgroundColor: .gray200, borderColor: .gray200, checkmarkColor: .gray00),
        unSelectedPalette: .init(backgroundColor: .gray00, borderColor: .gray200),
        disabledSelectedPalette: .init(backgroundColor: .gray50, borderColor: .gray50, checkmarkColor: .gray00),
        disabledUnselectedPalette: .init(backgroundColor: .gray00, borderColor: .gray50)
    )
}
