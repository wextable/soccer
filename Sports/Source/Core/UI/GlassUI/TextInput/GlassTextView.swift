//
//  GlassTextView.swift
//  GlassUI
//
//  Created by Owen Pierce on 6/9/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import UIKit

// swiftlint:disable file_length type_body_length
/// Custom textview with hint text, error text, accessory toolbar, validation blocks.
/// Hint text floats at the bottom as the user begins editing the text field.
/// Error or success text appear as hint text on validation.
///
/// # Discussion
/// - Zeplin Reference - https://zpl.io/aMg7YYz
///
/// # Example
///```swift
/// let commentView: GlassTextView = GlassTextView()
/// commentView.placeholderText = "Hint text"
/// commentView.text = "Some data entry"
/// commentView.characterLimit = 100
/// commentView.delegate = someUITextViewDelegateConformer
///```
public class GlassTextView: UIView, Accessible {

    public enum ResizingMode {
        case fixed
        case flexible
    }

    // MARK: - Private

    /// Top label above input field
    private var titleLabel: GlassLabel = .init(style: .captionRegular)
    private var titleLabelAsPlaceholderConstraints: [NSLayoutConstraint] = []
    private var titleLabelAsTitleConstraints: [NSLayoutConstraint] = []
    private var titleScale: CGFloat = 1

    /// Editable text view
    private let textView: UITextView = .init()
    private var textViewHeightConstraint: NSLayoutConstraint?
    private var textViewMinHeightConstraint: NSLayoutConstraint?
    private var textViewMaxHeightConstraint: NSLayoutConstraint?

    /// Bottom separator line
    private var separatorContainer: UIView = .init()
    private var separatorView: GlassDivider = .init()
    private var separatorWeightConstraint: NSLayoutConstraint?

    /// Label to show placeholder text if present
    private var placeholderLabel: GlassLabel = GlassLabel(style: .body1)

    /// Label to display hint text
    private let hintLabel: GlassLabel = .init(style: .captionRegular)
    private var successText: String?

    /// Label to display character count
    private let characterCountLabel: GlassLabel = .init(style: .captionRegular)

    /// Icon for status indication
    private let statusIconView: UIImageView = .init()
    private let errorIcon: GlassIcon = GlassIcon.exclamationCircleFill
    private let successIcon: GlassIcon? = GlassIcon.checkCircleFill

    /// The text that gets displayed on error label
    private var errorText: String? = nil {
        didSet {
            if errorText != oldValue {
                invalidateIntrinsicContentSize()
                updateComponentColors()
                updateHintLabel()
            }
        }
    }

    private var selectedSeparatorWeight: CGFloat {
        if textView.isFirstResponder {
            return 2
        } else {
            return 1
        }
    }

    private var titleColor: GlassColor {
        if textView.isFirstResponder {
            return GlassColor.gray200
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray100
        }
    }

    private var hintColor: GlassColor {
        if errorText != nil {
            return GlassColor.red100
        } else if isInputValid && validationBlock != nil && shouldShowSuccessState {
            return GlassColor.green100
        } else if textView.isFirstResponder {
            return GlassColor.gray100
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray100
        }
    }

    private var separatorColor: GlassColor {
        if errorText != nil {
            return GlassColor.red100
        } else if isInputValid && validationBlock != nil && shouldShowSuccessState {
            return GlassColor.green100
        } else if textView.isFirstResponder {
            return GlassColor.gray200
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray80
        }
    }

    private var characterCountLabelColor: GlassColor {
        if textView.text.count > characterLimit ?? Int.max {
            return GlassColor.red100
        } else if textView.isFirstResponder {
            return GlassColor.gray200
        } else {
            return GlassColor.gray100
        }
    }

    /// Accessory tool bar
    private lazy var accessoryToolbar: GlassAccessoryToolbar = {

        /// Uses custom toolbar if `customAccessoryToolbar` assigned
        /// Alternately use `setCustomAccessoryToolbar` method to assign specific actions on next, prev and done
        if let customToolbar = customAccessoryToolbar {
            return customToolbar
        }

        let toolbar = GlassAccessoryToolbar(doneAction: { [weak self] () -> Void in
            self?.doneEditing()
            }, prevAction: { [weak self] () -> Void in
                self?.doneEditing()
                self?.gotoPreviousTextField()
            }, nextAction: { [weak self] () -> Void in
                self?.doneEditing()
                self?.gotoNextTextField()
        })
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        return toolbar
    }()

    ///
    /// Returns the bounded height for the textView's current text, based on the current resizingMode.
    ///
    private var textHeight: CGFloat {
        switch resizingMode {
        case .flexible:
            let minHeight = minimumHeight ?? 0
            let maxHeight = maximumHeight ?? .greatestFiniteMagnitude
            let actualHeight = textView.sizeThatFits(CGSize(width: textView.frame.width,
                                                            height: .greatestFiniteMagnitude)).height
            let placeholderHeight = placeholderLabel.sizeThatFits(CGSize(width: placeholderLabel.frame.width,
                                                                         height: .greatestFiniteMagnitude)).height
            let adjustedHeight = placeholderHeight > actualHeight ? placeholderHeight : actualHeight

            if adjustedHeight < minHeight {
                return minHeight
            } else if adjustedHeight > maxHeight {
                return maxHeight
            } else {
                return adjustedHeight
            }
        case .fixed:
            return GlassSpacing.xLarge
        }
    }

    // MARK: - Public

    /// Text Field Delegate
    public weak var delegate: UITextViewDelegate?

    /// Default height of text view
    public static let defaultHeight: CGFloat = 148.0

    /// Minimum height of the text view.  Defaults to: nil
    public var minimumHeight: CGFloat? = nil {
        didSet { updateTextViewHeight() }
    }

    /// Maximum height of the text view.  Defaults to: GlassSpacing.xxLarge
    public var maximumHeight: CGFloat? = GlassSpacing.xxLarge {
        didSet { updateTextViewHeight() }
    }

    /// Whether the text view height is fixed or expands with user input
    public var resizingMode: ResizingMode = .fixed {
        didSet { updateTextViewHeight() }
    }

    /// Text input into the text field
    open var text: String? {
        get {
            return textView.text
        } set {
            // update error status when changing text programmatically
            textView.text = newValue
            textViewDidChange(textView)
            textViewDidEndEditing(textView)
        }
    }

    /// Text for the top title label - also displays as the placeholder when unfocused
    open var titleText: String? {
        didSet {
            titleLabel.text = titleText
            setTextViewAccessibilityDescription()
        }
    }

    /// Text field placeholder text, appears when field is focused and text is empty
    open var placeholderText: String? = nil {
        didSet {
            var placeholder = placeholderText ?? ""
            // When any text is entered, remove any extra hint help suffix from field label
            for suffix in ["*", "(required)", "(Required)"] {
                if placeholder.hasSuffix(suffix) {
                    placeholder = String(placeholder.dropLast(suffix.count))
                    break
                }
            }
            placeholderLabel.text = placeholder
            setTextViewAccessibilityDescription()
            updateTextViewHeight()
            updateLayout(animated: false)
        }
    }

    /// Error presented when input exceeds character limit.
    open var inputTooLongErrorString: String = "Input is too long"

    /// Helper text to give context to expected input in the text field, appears below the divider
    open var hintText: String? = nil {
        didSet {
            updateHintLabel()
        }
    }

    /// Field should be validated to show errors as each character is typed
    open var shouldValidateEachTextChange = false

    /// Field should show right success icon and change color to reflect success state.
    open var shouldShowSuccessState = false

    open weak var previousField: UIResponder? {
        didSet { accessoryToolbar.setEnabled(previousField != nil, button: .prev) }
    }

    open weak var nextField: UIResponder? {
        didSet { accessoryToolbar.setEnabled(nextField != nil, button: .next) }
    }

    /// default validation: true if not empty
    open var validationBlock: ((String) -> String?)?

    /// True if and only if input is evaluated to be valid.
    /// Empty input should not be included, as this triggers the Success state.
    open var isInputValid: Bool = false {
        didSet {
            if validationBlock != nil {
                updateComponentColors()
                updateHintLabel()
            }
        }
    }

    /// Maximum number of characters allowed for valid input.
    public var characterLimit: Int? {
        didSet {
            updateCharacterCountLabel()
        }
    }

    /// Bool to show accessory toolbar over keyboard with "< >   Done"
    open var showAccessoryToolbar: Bool = true {
        didSet {
            if showAccessoryToolbar {
                textView.inputAccessoryView = accessoryToolbar
            } else {
                textView.inputAccessoryView = nil
            }
        }
    }

    /// Keyboard uses custom toolbar if `customAccessoryToolbar` assigned
    /// Alternately use `setCustomAccessoryToolbar` method to assign specific actions on next, prev and done
    @objc open var customAccessoryToolbar: GlassAccessoryToolbar? {
        didSet {
            guard let toolbar = customAccessoryToolbar else { return }
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            accessoryToolbar = toolbar
            showAccessoryToolbar = true
        }
    }

    // MARK: - Text Field behavior

    /// Controls autocapitalization behavior for a text field.
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { return textView.autocapitalizationType }
        set { textView.autocapitalizationType = newValue }
    }

    /// Controls keyboard autocorrection behavior for a text field.
    public var autocorrectionType: UITextAutocorrectionType {
        get { return textView.autocorrectionType }
        set { textView.autocorrectionType = newValue }
    }

    /// Controls the annotation of misspelled words for the text field.
    public var spellCheckingType: UITextSpellCheckingType {
        get { return textView.spellCheckingType }
        set { textView.spellCheckingType = newValue }
    }

    /// Controls the keyboard type of the text field.
    public var keyboardType: UIKeyboardType {
        get { return textView.keyboardType }
        set { textView.keyboardType = newValue }
    }

    // MARK: - Init Methods

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    //swiftlint:disable function_body_length
    private func commonInit() {

        translatesAutoresizingMaskIntoConstraints = false

        setupTextView()
        setupTitleLabel()
        setupPlaceholderLabel()
        setupSeparatorView()
        setupHintLabel()

        addAutoLayoutSubview(hintLabel)
        addAutoLayoutSubview(characterCountLabel)
        addAutoLayoutSubview(statusIconView)
        addConstraints()

        updateCharacterCountLabel()

        accessibilityElements = [textView, hintLabel, characterCountLabel]
        setTextViewAccessibilityDescription()
        assignAccessibilityIdentifiers()
        errorText = nil
    }

    /// Removes error message and resets validation
    public func clearValidation() {
        errorText = nil
        isInputValid = false
    }

    /// Returns true if text field input is valid
    @discardableResult public func validateTextView() -> Bool {
        let unwrappedText = text ?? ""

        // Suppress errors on a field being edited, unless it's empty or we're validating each character
        if isFirstResponder && (!shouldValidateEachTextChange || unwrappedText.isEmpty) {
            errorText = nil
            isInputValid = false
            setTextViewAccessibilityDescription()
            return true
        } else if let error = validationBlock?(unwrappedText) {
            errorText = error
            isInputValid = false
            setTextViewAccessibilityDescription()
            return false
        } else if unwrappedText.isEmpty {
            errorText = nil
            isInputValid = false
            setTextViewAccessibilityDescription()
            return true
        } else if let limit = characterLimit, unwrappedText.count > limit {
            errorText = inputTooLongErrorString
            isInputValid = false
            setTextViewAccessibilityDescription()
            return false
        } else {
            isInputValid = validationBlock != nil
            errorText = nil
            setTextViewAccessibilityDescription()
            return true
        }
    }

    @discardableResult open override func resignFirstResponder() -> Bool {
        let superResignResponder = super.resignFirstResponder()
        validateTextView()
        updateComponentColors()
        textView.resignFirstResponder()

        // Voiceover focus should fallback on textView once keyboard is dismissed
        UIAccessibility.post(notification: .layoutChanged, argument: textView)

        return superResignResponder
    }

    @discardableResult open override func becomeFirstResponder() -> Bool {
        let superBecomeFirstResponder = super.becomeFirstResponder()
        if superBecomeFirstResponder {
            errorText = nil
            validateTextView() // Clear errors when editing begins
            updateComponentColors()
        }
        textView.becomeFirstResponder()
        return superBecomeFirstResponder
    }

    // MARK: - Text View Methods

    private let titleLabelHeight: CGFloat = GlassSpacing.small

    @objc func doneEditing() { _ = resignFirstResponder() }
    @objc func gotoPreviousTextField() { _ = previousField?.becomeFirstResponder() }
    @objc func gotoNextTextField() { _ = nextField?.becomeFirstResponder() }
}

// MARK: - Setup

extension GlassTextView {

    private func setupHintLabel() {
        hintLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        hintLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    private func setupTitleLabel() {
        titleLabel.textColor = titleColor.uiColor
        titleLabel.font = GlassFont.body1().uiFont
        titleLabel.isAccessibilityElement = false
        addAutoLayoutSubview(titleLabel)

        titleLabelAsTitleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: GlassSpacing.small)
        ]

        titleLabelAsTitleConstraints.forEach({ $0.isActive = false })

        titleLabelAsPlaceholderConstraints = [
            titleLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall)
        ]
    }

    private func setupTextView() {
        textView.textContainerInset =
            UIEdgeInsets(top: 0, left: -GlassSpacing.xxSmall, bottom: 0, right: 0)
        textView.delegate = self
        textView.font = GlassFont.body1().uiFont
        textView.backgroundColor = .clear
        textView.inputAccessoryView = accessoryToolbar
        textView.isScrollEnabled = true
        textView.isSelectable = true
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
        addAutoLayoutSubview(textView)
    }

    private func setupPlaceholderLabel() {
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = titleColor.uiColor
        placeholderLabel.isAccessibilityElement = false
        placeholderLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        placeholderLabel.setContentHuggingPriority(.required, for: .vertical)
        addAutoLayoutSubview(placeholderLabel)
    }

    private func setupSeparatorView() {
        separatorView.dividerColor = separatorColor
        separatorView.layer.cornerRadius = 2.0
        separatorView.clipsToBounds = true
        separatorContainer.addAutoLayoutSubview(separatorView)
        addAutoLayoutSubview(separatorContainer)
    }
}

// MARK: - Configuration

extension GlassTextView {

    //swiftlint:enable function_body_length

    public func configure(_ configuration: GlassTextViewConfiguration) {
        placeholderText = configuration.placeholderText
        text = configuration.text
        titleText = configuration.titleText
        hintText = configuration.hintText
        placeholderText = configuration.placeholderText
        characterLimit = configuration.characterLimit
        validationBlock = configuration.validationBlock
        shouldShowSuccessState = configuration.shouldShowSuccessState ?? false
        shouldValidateEachTextChange = configuration.shouldValidateEachTextChange ?? false
        nextField = configuration.next
        previousField = configuration.previous
    }

    private func updateLayout(animated: Bool = true) {

        let textFieldActive = !textView.text.isEmpty || textView.isFirstResponder
        let placeholderLabelShouldHide = textFieldActive
        let titleLabelScale: CGFloat

        // If the title text is not empty and placeholder text is empty or hidden
        if titleText?.isEmpty != true && (placeholderText?.isEmpty != false || placeholderLabelShouldHide) {
             if textFieldActive {
                // Title label should be positioned above the text field
                titleLabelAsPlaceholderConstraints.forEach({ $0.isActive = false })
                titleLabelAsTitleConstraints.forEach({ $0.isActive = true })
                titleLabelScale = 0.75

             } else {
                titleLabelAsPlaceholderConstraints.forEach({ $0.isActive = true })
                titleLabelAsTitleConstraints.forEach({ $0.isActive = false })
                titleLabelScale = 1
             }
        } else {
            titleLabelAsPlaceholderConstraints.forEach({ $0.isActive = false })
            titleLabelAsTitleConstraints.forEach({ $0.isActive = true })
            titleLabelScale = 0.75
        }

        let applyValues = { [weak self] in
            guard let self = self else { return }

            self.titleLabel.textColor = self.titleColor.uiColor
            self.placeholderLabel.alpha = placeholderLabelShouldHide ? 0 : 1
            self.separatorWeightConstraint?.constant = self.selectedSeparatorWeight
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                applyValues()
            })
        } else {
            applyValues()
        }

        scaleTitleLabel(to: titleLabelScale, animated: animated)
    }

    private func updateTextViewHeight() {
        switch resizingMode {
        case .flexible:
            textViewHeightConstraint?.constant = self.textHeight
            textViewMinHeightConstraint?.constant = self.minimumHeight ?? 0
            textViewMaxHeightConstraint?.constant = self.maximumHeight ?? .greatestFiniteMagnitude
        default: return
        }
    }

    private func scaleTitleLabel(to scale: CGFloat, animated: Bool) {
        guard let titleText = titleText, !titleText.isEmpty, titleLabel.bounds.width != 0 else { return }
        titleScale = scale

        let transform: CGAffineTransform
        if scale == 1 {
            transform = .identity
        } else {
            transform = CGAffineTransform
                    .init(translationX: -titleLabel.bounds.width/2, y: 0)
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: titleLabel.bounds.width/2, y: 0)
        }

        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.titleLabel.transform = transform
            })
        } else {
            titleLabel.transform = transform
        }
    }
}

// MARK: - User Interface

extension GlassTextView {

    /// This also colors the separator to match the placeholderText
    private func updateComponentColors() {
        hintLabel.textColor = hintColor.uiColor
        titleLabel.textColor = titleColor.uiColor
        separatorView.dividerColor = separatorColor
        characterCountLabel.textColor = characterCountLabelColor.uiColor
    }

    private func updateHintLabel() {
        if errorText != nil {
            hintLabel.text = errorText
            let iconImage = errorIcon.imageSize12()
            statusIconView.image = iconImage?.withTintColor(GlassColor.red100.uiColor)
            statusIconView.isHidden = false
        } else if isInputValid && validationBlock != nil &&
            successText != nil && shouldShowSuccessState {
            hintLabel.text = successText
            let iconImage = successIcon?.imageSize12()
            statusIconView.image = iconImage?.withTintColor(GlassColor.green100.uiColor)
            statusIconView.isHidden = false
        } else {
            hintLabel.text = hintText
            statusIconView.isHidden = true
        }

        // If hint label is blank, hide the hint label so that VoiceOver doesn't read it.
        hintLabel.isHidden = hintLabel.text?.isEmpty ?? true
        updateAccessibleElements()
    }

    private func updateCharacterCountLabel() {
        if let limit = characterLimit {
            characterCountLabel.isHidden = false
            characterCountLabel.text = "\(textView.text.count)/\(limit)"
            characterCountLabel.accessibilityLabel = "\(textView.text.count) out of \(limit) characters"
            announceRemainingCharacter()
        } else {
            characterCountLabel.isHidden = true
        }
        updateAccessibleElements()
    }

    private func updateAccessibleElements() {
        var accessibleElements: [UIView] = [textView]
        accessibleElements.append(contentsOf: [hintLabel, characterCountLabel]
                                    .compactMap { $0 }
                                    .filter { !$0.isHidden }
        )
        accessibilityElements = accessibleElements
    }

    // The count will be announced every 10th character
    private func announceRemainingCharacter() {
        let count = textView.text.count
        guard count.isMultiple(of: 10) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            UIAccessibility.post(notification: .announcement, argument: self?.characterCountLabel.accessibilityLabel)
        }
    }
}

// MARK: - Layout

extension GlassTextView {

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewHeight()
        updateLayout(animated: false)
    }

    // swiftlint:disable function_body_length
    private func addConstraints() {

        var constraints: [NSLayoutConstraint] = []

        // Placeholder Constraints
        constraints.append(contentsOf: [
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])

        // Text Field Constraints
        constraints.append(contentsOf: [
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.small),
            textView.heightAnchor.constraint(greaterThanOrEqualTo: placeholderLabel.heightAnchor)
        ])
        let textViewMinHeightConstraint =
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight ?? 0)
        let textViewMaxHeightConstraint =
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight ?? .greatestFiniteMagnitude)
        let textViewHeightConstraint =
            textView.heightAnchor.constraint(equalToConstant: textHeight)

        constraints.append(textViewHeightConstraint)
        constraints.append(textViewMinHeightConstraint)
        constraints.append(textViewMaxHeightConstraint)
        self.textViewHeightConstraint = textViewHeightConstraint
        self.textViewMinHeightConstraint = textViewMinHeightConstraint
        self.textViewMaxHeightConstraint = textViewMaxHeightConstraint

        // Separator Constraints
        constraints.append(contentsOf: [
            separatorContainer.topAnchor.constraint(greaterThanOrEqualTo: textView.bottomAnchor,
                                                    constant: GlassSpacing.xSmall),
            separatorContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        constraints.append(contentsOf: [
            separatorView.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor),
            separatorView.heightAnchor.constraint(equalTo: separatorContainer.heightAnchor)
        ])

        let separatorWeightConstraint =
            separatorContainer.heightAnchor.constraint(equalToConstant: selectedSeparatorWeight)
        constraints.append(separatorWeightConstraint)
        self.separatorWeightConstraint = separatorWeightConstraint

        // Hint Label Constraints
        constraints.append(contentsOf: [
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hintLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
                                                constant: -GlassSpacing.small),
            hintLabel.topAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                           constant: GlassSpacing.xxSmall + 1),
            hintLabel.heightAnchor.constraint(equalToConstant: GlassSpacing.small),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                              constant: -GlassSpacing.mediumSmall),
            statusIconView.leadingAnchor.constraint(equalTo: hintLabel.trailingAnchor,
                                                    constant: GlassSpacing.xxSmall),
            statusIconView.heightAnchor.constraint(equalToConstant: GlassSpacing.small),
            statusIconView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            statusIconView.topAnchor.constraint(equalTo: hintLabel.topAnchor)
        ])

        // Character Count Label Constraints
        constraints.append(contentsOf: [
            characterCountLabel.topAnchor.constraint(equalTo: hintLabel.topAnchor),
            characterCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate(constraints)
        setNeedsLayout()
    }
}

// MARK: - UITextView Delegation

extension GlassTextView: UITextViewDelegate {

    private func editingStateDidChange() {
        separatorView.dividerColor = separatorColor
        updateLayout()
        updateComponentColors()
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        editingStateDidChange()
        delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        editingStateDidChange()
        delegate?.textViewDidEndEditing?(textView)
    }

    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        return delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    public func textViewDidChange(_ textView: UITextView) {
        validateTextView()
        updateCharacterCountLabel()
        updateLayout(animated: false)
        setTextViewAccessibilityDescription()
        updateTextViewHeight()
        delegate?.textViewDidChange?(textView)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction)
            ?? true
    }
}

// MARK: - Accessibility

extension GlassTextView {

    /// Update accessibility so voice over is helpful
    open func setTextViewAccessibilityDescription() {
        if let accessibilityText = titleText ?? placeholderText {
            if text == "" && errorText == nil {
                // Empty textfield - clear it, and it speaks placeholder text
                textView.accessibilityLabel = accessibilityText
                textView.accessibilityValue = nil
            } else if text == "" {
                textView.accessibilityLabel = accessibilityText
                textView.accessibilityValue = errorText
            } else {
                textView.accessibilityLabel = accessibilityText
                let voiceOverText = text ?? ""
                textView.accessibilityValue = (errorText == nil) ?
                    voiceOverText : "\(voiceOverText).  Not acceptable.  \(errorText!)"
            }
        }

        if let titleText = titleText, let hintText = hintLabel.text {
            hintLabel.accessibilityLabel = "Hint for text field \(titleText): \(hintText)"
        }
    }
}

public struct GlassTextViewConfiguration {
    public var placeholderText: String?
    public var text: String?
    public var titleText: String?
    public var hintText: String?
    public var characterLimit: Int?
    public var validationBlock: ((String) -> String?)?
    public var shouldValidateEachTextChange: Bool?
    public var shouldShowSuccessState: Bool?
    public var next: UIResponder?
    public var previous: UIResponder?

    public init(placeholderText: String? = nil,
                text: String? = nil,
                titleText: String? = nil,
                hintText: String? = nil,
                characterLimit: Int? = nil,
                validationBlock: ((String) -> String?)? = nil,
                shouldValidateEachTextChange: Bool? = nil,
                shouldShowSuccessState: Bool? = nil,
                next: UIResponder? = nil,
                previous: UIResponder? = nil) {
        self.placeholderText = placeholderText
        self.text = text
        self.titleText = titleText
        self.hintText = hintText
        self.characterLimit = characterLimit
        self.validationBlock = validationBlock
        self.shouldValidateEachTextChange = shouldValidateEachTextChange
        self.shouldShowSuccessState = shouldShowSuccessState
        self.next = next
        self.previous = previous
    }
}

#if DEBUG
extension GlassTextView {
    var testHooks: TestHooks { .init(target: self) }

    class TestHooks {
        let target: GlassTextView
        var errorText: String? { return target.errorText }
        var textView: UITextView! { return target.textView }
        var characterCountLabel: GlassLabel { return target.characterCountLabel }

        init(target: GlassTextView) {
            self.target = target
        }
    }
}
#endif
