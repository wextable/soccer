//
//  GlassFilterChip.swift
//  GlassUI
//
//  Created by Antony Raphel on 8/13/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import UIKit

/// Filter Chip are text content with an optional leading or trailing icon or both.
///
/// # Reference
/// [Zeplin Reference](https://zpl.io/2vjGvwn)
///
/// # Example
/// ```swift
/// let model = GlassFilterChip.Model(title: "title", filterStyle: .leftIcon(.apparel))
/// let filterChip = GlassFilterChip(model: model)
/// ```
public class GlassFilterChip: BaseView {

    // MARK: - Model

    public struct Model {

        /// Apply the filter chip style
        public enum FilterStyle: Equatable {
            /// Optional leading icon with text
            case leftIcon(GlassIcon?)
            /// Optional trailing icon with text
            case rightIcon(GlassIcon?)
            /// Optional leading & trailing icon with text
            case bothIcons(GlassIcon?, GlassIcon?)
            /// Only text
            case titleOnly

            var leftIcon: GlassIcon? {
                switch self {
                case .leftIcon(let icon): return icon
                case .bothIcons(let icon, _): return icon
                default: return .none
                }
            }

            var rightIcon: GlassIcon? {
                switch self {
                case .rightIcon(let icon): return icon
                case .bothIcons(_, let icon): return icon
                default: return .none
                }
            }
        }

        let title: String
        let isSelected: Bool
        let filterStyle: FilterStyle

        public init(title: String, filterStyle: FilterStyle = .titleOnly, isSelected: Bool = false) {
            self.title = title
            self.isSelected = isSelected
            self.filterStyle = filterStyle
        }
    }

    // MARK: - Properties

    private struct Layout {
        static let verticalInsets: CGFloat = 10
        static let horizontalInsets: CGFloat = 12
        static let cornerRadius: CGFloat = 20
        static let height: CGFloat = 40
    }

    private let stackView = UIStackView(axis: .horizontal)
    private let label = GlassLabel(style: .body2)
    private let leftIconImageView = UIImageView()
    private let rightIconImageView = UIImageView()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private var trailingConstraint = NSLayoutConstraint()
    private var leadingConstraint = NSLayoutConstraint()

    public var tapAction: (() -> Void)?

    public var title: String = "" {
        didSet {
            label.text = title
            updateAccessibility()
        }
    }

    public var isSelected: Bool = false {
        didSet {
            updateUI()
        }
    }

    public var model: Model {
        didSet {
            applyModel()
        }
    }

    public init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: - Construction

    public override func constructView() {
        super.constructView()

        clipsToBounds = true
        layer.cornerRadius = Layout.cornerRadius

        // stackView
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = GlassSpacing.xxSmall

        // leftIconImageView
        leftIconImageView.contentMode = .scaleAspectFit

        // rightIconImageView
        rightIconImageView.contentMode = .scaleAspectFit

        // accessibility
        label.isAccessibilityElement = false
        accessibilityTraits = [.button]
        isAccessibilityElement = true
    }

    public override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([leftIconImageView, label, rightIconImageView])
        addAutoLayoutSubview(stackView)

        tapGestureRecognizer.addTarget(self, action: #selector(didPressAction))
        addGestureRecognizer(tapGestureRecognizer)
    }

    public override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        leadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            leftIconImageView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            rightIconImageView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            leadingConstraint,
            trailingConstraint,
            stackView.constraints(pinningTo: self,
                                  edges: [.vertical],
                                  insets: .init(vertical: Layout.verticalInsets)),
            heightAnchor.constraint(equalToConstant: Layout.height)
        ])
    }

    private func applyModel() {
        title = model.title
        isSelected = model.isSelected

        leftIconImageView.image = model.filterStyle.leftIcon?.imageSize16()?.withRenderingMode(.alwaysTemplate)
        leftIconImageView.isHidden = model.filterStyle.leftIcon == .none
        rightIconImageView.image = model.filterStyle.rightIcon?.imageSize16()?.withRenderingMode(.alwaysTemplate)
        rightIconImageView.isHidden = model.filterStyle.rightIcon == .none

        leadingConstraint.constant = leftIconImageView.isHidden ? GlassSpacing.small : Layout.horizontalInsets
        trailingConstraint.constant = rightIconImageView.isHidden ? -GlassSpacing.small : -Layout.horizontalInsets
        layoutIfNeeded()
    }

    private func updateUI() {
        updateAccessibility()

        let contentForegroundColor: GlassColor = isSelected ? .white : .black
        let contentBackgroundColor: GlassColor = isSelected ? .blue130 : .gray20
        UIView.animate(withDuration: GlassAnimation.animationTimeShort) {
            self.leftIconImageView.tintColor = contentForegroundColor.uiColor
            self.rightIconImageView.tintColor = contentForegroundColor.uiColor
            self.label.textColor = contentForegroundColor.uiColor
            self.backgroundColor = contentBackgroundColor.uiColor
        }
    }

    // MARK: - Action

    @objc private func didPressAction() {
        isSelected.toggle()
        updateUI()
        UIAccessibility.post(notification: .announcement, argument: self)
        tapAction?()
    }

    // MARK: - Accessibility

    private func updateAccessibility() {
        var title = label.text ?? ""
        title += isSelected ? " selected" : " not selected"
        accessibilityLabel = title
    }
}

#if DEBUG
extension GlassFilterChip {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassFilterChip

        fileprivate init(target: GlassFilterChip) {
            self.target = target
        }

        var leftIconImageView: UIImageView { return target.leftIconImageView }
        var label: GlassLabel { return target.label }
        var rightIconImageView: UIImageView { return target.rightIconImageView }

        func didPressAction() {
            target.didPressAction()
        }
    }
}
#endif
