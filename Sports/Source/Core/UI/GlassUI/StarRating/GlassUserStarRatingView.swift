//
//  GlassUserStarRatingView.swift
//  GlassUI
//
//  Created by Vishal Madheshia on 05/29/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Foundation
import UIKit

// MARK: - GlassUserStarRatingViewDelegate
/// A set of method(s) for monitoring the interaction of a user star rating view.
public protocol GlassUserStarRatingViewDelegate: AnyObject {

    /// Tells the delegate that a `rating` has been selected.
    func glassUserStarRatingView(_: GlassUserStarRatingView, didSelectRating rating: Int)
}

// MARK: - GlassUserStarRatingViewAccessibilityDataSource
/// An object that adopts the `GlassUserStarRatingViewAccessibilityDataSource` protocol is responsible for providing
/// custom accessibility information required for the rating view.
public protocol GlassUserStarRatingViewAccessibilityDataSource: AnyObject {

    /// Asks the data source to return the accessibility title for the given `rating`.
    func glassUserStarRatingView(_: GlassUserStarRatingView, accessibilityActionTitleForRating rating: Int?) -> String
}

// MARK: - GlassUserStarRatingView
/// A interactive star rating view.
public final class GlassUserStarRatingView: BaseView {

    public var model: Model {
        didSet { applyModel() }
    }

    public weak var delegate: GlassUserStarRatingViewDelegate?

    public weak var accessibilityDataSource: GlassUserStarRatingViewAccessibilityDataSource? {
        didSet { setUpAccessibilityActions() }
    }

    private let starStackView: UIStackView

    private var starViews: [GlassUserStarView] {
        return starStackView.arrangedSubviews.compactMap({ $0 as? GlassUserStarView })
    }

    /// Creates an instance of star rating view without a rating.
    public init(model: GlassUserStarRatingView.Model = .init()) {
        starStackView = UIStackView()
        starStackView.distribution = .fillEqually
        starStackView.spacing = GlassSpacing.xSmall
        self.model = model
        super.init(frame: .zero)

        accessibilityLabel = "user-star-rating.starRating".localize()
        accessibilityHint = "user-star-rating.starRatingHint".localize()
        isAccessibilityElement = true

        setUpStars()
        applyModel()

        addAutoLayoutSubview(starStackView)
        NSLayoutConstraint.activate([
            starStackView.topAnchor.constraint(equalTo: topAnchor),
            starStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            starStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            starStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didReachForTheStars(_:)))
        addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReachForTheStars(_:)))
        addGestureRecognizer(tapGestureRecognizer)

    }

    // MARK: Interactions
    @objc
    private func didReachForTheStars(_ dreams: UIGestureRecognizer) {
        updateStars(fromTouching: dreams.location(in: self))

        if dreams.state == .ended {
            notifyDelegateOfRatingSelection()
        }
    }

    // MARK: Helpers
    private func updateStars(fromTouching point: CGPoint) {
        guard let selectedStar = starViews.last(where: { point.x > convert($0.bounds.origin, from: $0).x }) else {
            return
        }
        model.rating = selectedStar.model.rating
        selectRating(selectedStar.model.rating)
    }

    private func selectRating(_ rating: Int?) {
        assert(rating == nil || model.ratingRange.contains(rating!), "Invalid raing=\(String(describing: rating))")

        starViews.forEach({ $0.model.state = $0.model.rating <= (rating ?? 0) ? .selected : .unselected })
        setAccessibilityValue(for: rating)
    }

    private func notifyDelegateOfRatingSelection() {
        guard let rating = model.rating else { return }

        delegate?.glassUserStarRatingView(self, didSelectRating: rating)
    }
}

// MARK: - GlassUserStarRatingView ViewModel
extension GlassUserStarRatingView {

    /// The model powering the Glass user star rating view.
    public struct Model {

        /// The number of stars to display.
        /// - Invariant: `starCount` will not have a value of less than `1`.
        var starCount: Int! {
            didSet {
                starCount =  max(1, starCount)
            }
        }

        /// The selected rating that corresponds to the number of stars filled in.
        /// - Invariant: The value is in the range `1...starCount` or `nil`.
        /// - Note: Setting a `rating` to a value outside of `1...starCount` resets `rating` to `nil`.
        public var rating: Int? {
            didSet {
                if !ratingRange.contains(rating ?? 0) {
                    self.rating = nil
                }
            }
        }
        /// The preferred size of each star.
        public var starSize: GlassIcon.Size

        /// The image of the stars when selected.
        public var fillStarIcon: GlassIcon

        /// The image of the stars when unselected.
        public var starIcon: GlassIcon

        var hasSelected: Bool {
            return rating != nil
        }

        var ratingRange: ClosedRange<Int> {
            return 1...(starCount)
        }

        public init(starCount: Int = 5,
                    rating: Int? = nil,
                    starSize: GlassIcon.Size = .size32,
                    fillStarIcon: GlassIcon = .starFill,
                    starIcon: GlassIcon = .star) {
            self.starSize = starSize
            self.fillStarIcon = fillStarIcon
            self.starIcon = starIcon
            self.setStarCount(starCount)
            self.setRating(rating)
        }

        private mutating func setStarCount(_ starCount: Int) {
            self.starCount = max(1, starCount)
        }

        private mutating func setRating(_ rating: Int?) {
            if ratingRange.contains(rating ?? 0) {
                self.rating = rating
            } else {
                self.rating = nil
            }
        }
    }
}

// MARK: - Apply Model

extension GlassUserStarRatingView {
    private func applyModel() {
        starViews.forEach({ $0.model.fillStarIcon = model.fillStarIcon })
        starViews.forEach({ $0.model.starIcon = model.starIcon })
        selectRating(model.rating)
    }

    private func setUpStars() {

        starViews.forEach({ $0.removeFromSuperview() })

        let newStarViews = (1...model.starCount).map { (rating) -> GlassUserStarView in
            let starView = GlassUserStarView()
            starView.model = GlassUserStarView.Model(size: model.starSize, rating: rating)
            return starView
        }

        newStarViews.forEach(starStackView.addArrangedSubview(_:))
        setUpAccessibilityActions()
    }
}

// MARK: Accessibility

extension GlassUserStarRatingView {

    public override func accessibilityActivate() -> Bool {
        selectAccessibilityRating(model.ratingRange.upperBound)
        return true
    }

    private var defaultAccessibilityTitles: [String] {
        return model.ratingRange.map({ "user-star-rating.userStarRating".localize($0) })
    }

    private func setUpAccessibilityActions() {
        let titles = model.ratingRange.map({ accessibilityActionTitle(for: $0) })

        accessibilityCustomActions = zip(model.ratingRange, titles).map { (rating, title)
            -> AccessibilityCustomAction in
            return AccessibilityCustomAction(name: title) { [unowned self] _ in
                self.selectAccessibilityRating(rating)
            }
        }
    }

    private func selectAccessibilityRating(_ rating: Int?) {
        model.rating = rating
        selectRating(rating)
        UIAccessibility.post(
            notification: .announcement,
            argument: "user-star-rating.userStarRatingSelectedFormat".localize(
                self.accessibilityActionTitle(for: rating))
        )
        notifyDelegateOfRatingSelection()
    }

    private func accessibilityActionTitle(for rating: Int?) -> String {
        return accessibilityDataSource?.glassUserStarRatingView(self, accessibilityActionTitleForRating: rating)
            ?? defaultAccessibilityActionTitle(for: rating)
    }

    private func defaultAccessibilityActionTitle(for rating: Int?) -> String {
        // safe due to invariant that `rating` is in `1...starCount`
        return rating.map({ defaultAccessibilityTitles[$0 - 1] }) ?? "user-star-rating.noRating".localize()
    }

    private func setAccessibilityValue(for rating: Int?) {
        accessibilityValue = accessibilityActionTitle(for: rating)
    }
}

// MARK: - TestHooks

#if DEBUG
extension GlassUserStarRatingView {
    var testHooks: TestHooks {
        return TestHooks(target: self)
    }

    struct TestHooks {
        private let target: GlassUserStarRatingView

        fileprivate init(target: GlassUserStarRatingView) {
            self.target = target
        }

        var hasSelected: Bool {
            return target.model.hasSelected
        }

        var starStackView: UIStackView {
            return target.starStackView
        }

        var starViews: [GlassUserStarView] {
            return target.starViews
        }
    }
}
#endif
