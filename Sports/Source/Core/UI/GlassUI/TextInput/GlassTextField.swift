//
//  GlassTextField.swift
//  GlassUI
//
//  Created by Owen Pierce on 4/27/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import Combine
import UIKit
//import WalmartPlatform

open class StringFormatter: Transform<String, String> { }

// swiftlint:disable file_length type_body_length
/// Custom textfield with hint text, error text, accessory toolbar, validation blocks.
/// Hint text floats at the bottom as the user begins editing the text field.
/// Error or success text appear as hint text on validation.
///
/// # Discussion
/// - Zeplin Reference - https://zpl.io/2G0DQzj
///
/// # Example
///```swift
/// let errorField: GlassTextField = GlassTextField()
/// errorField.placeholderText = "Hint text"
/// errorField.text = "Some invalid entry"
/// errorField.errorString = "Error message"
/// errorField.validationBlock = { _ in return ["Some validation failed"] }
/// errorField.validateTextField()
/// errorField.customAccessoryToolbar = GlassAccessoryToolbar(doneAction: {
///     log("Done")
///     self.endEditing(true)
/// }, cancelAction: {
///     log("Cancel")
///     self.endEditing(true)
/// })
///```
open class GlassTextField: UIView, Accessible, GlassPII {

    /// Default height of text field
    public static let defaultHeight: CGFloat = 56.0

    // MARK: - Private

    private var tasks = Set<AnyCancellable>()

    private let selectedSeparatorWeight: CGFloat = 2.0

    /// Top label above input field
    private var titleLabel: GlassLabel!
    private var titleLabelAsPlaceholderConstraints: [NSLayoutConstraint]!
    private var titleLabelAsTitleConstraints: [NSLayoutConstraint]!

    /// Editable text field
    private lazy var textField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.delegate = self
        textField.font = GlassFont.body1().uiFont
        textField.backgroundColor = .clear
        textField.inputAccessoryView = accessoryToolbar

        return textField
    }()

    /// Left aligned icon image view
    private var leftIconImageView: UIImageView!

    /// Right aligned delete icon button.
    /// Visible only when editing text.
    private var rightDeleteIconButton: GlassIconButton!

    /// Right aligned success icon image view
    /// Visible only when not editing text and input is valid
    private var rightSuccessIconView: UIImageView!

    /// Button to toggle secure text entry
    private var securityEntryToggleButton: GlassLinkButton!

    /// Bottom separator line
    private var separatorContainer: UIView!
    private var separatorView: GlassDivider!
    private var focusedSeparatorViewTopConstraint: NSLayoutConstraint!
    private var unfocusedSeparatorViewTopConstraint: NSLayoutConstraint!

    /// Label to display hint text
    private var hintLabel: GlassLabel!

    /// Optional stringFormatter. This allows GlassTextfield to easily and automatically
    /// format its text for you
    public var formatter: StringFormatter?

    /// Icon for status indication
    private var statusIconView: UIImageView!

    private let errorIcon: GlassIcon = GlassIcon.exclamationCircleFill
    private var successIcon: GlassIcon? = GlassIcon.checkCircleFill {
        didSet {
            let successImage = successIcon?.imageSize24()
            rightSuccessIconView.image = successImage?.withTintColor(GlassColor.green100.uiColor)
        }
    }

    private var successText: String?

    private var titleColor: GlassColor {
        if textField.isFirstResponder {
            return GlassColor.gray200
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray100
        }
    }

    private var hintColor: GlassColor {
        if errorMessage != nil {
            return GlassColor.red100
        } else if isInputValid && validationBlock != nil && shouldShowSuccessState {
            return GlassColor.green100
        } else if textField.isFirstResponder {
            return GlassColor.gray100
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray100
        }
    }

    private var separatorColor: GlassColor {
        if errorMessage != nil {
            return GlassColor.red100
        } else if isInputValid && validationBlock != nil && shouldShowSuccessState {
            return GlassColor.green100
        } else if textField.isFirstResponder {
            return GlassColor.gray200
        } else if isUserInteractionEnabled != true {
            return GlassColor.gray50
        } else {
            return GlassColor.gray80
        }
    }

    private var leftIconAlpha: CGFloat {
        if leftIcon?.isSymbol == false && !textField.isFirstResponder {
            return 0.5
        } else {
            return 1
        }
    }

    private var leftIconColor: GlassColor? {
        if leftIcon?.isSymbol == true {
            if textField.isFirstResponder {
                return GlassColor.gray200
            } else {
                return GlassColor.gray100
            }
        } else {
            return nil
        }
    }

    private var rightIconColor: GlassColor {
        if isUserInteractionEnabled {
            return GlassColor.gray200
        } else {
            return GlassColor.gray50
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

        return toolbar
    }()

    private struct DefaultText {
        static let error = NSLocalizedString("This field is required", comment: "Default text on error label")
        static let placeholderText = NSLocalizedString("No hint/placeholder", comment: "Default text on hint label")
        static let accessibilityValue = NSLocalizedString("hidden", comment: "Default accessibility Value")
        static let clearFieldAccessibilityLabel =
            NSLocalizedString("Clear entry", comment: "accessibilityLabel for rightDeleteIconButton")
    }

    private var _textFieldAccessibilityHint: String?

    ///
    /// Flag to keep track if call to `setTextFieldAccessibilityDescription` is preceeded by delegate
    /// call to `textField(_:shouldChangeCharactersIn:replacementString:)`.  Used to determine
    /// if accessibility announcement is needed.  Property reset each time `setTextFieldAccessibilityDescription`
    /// is called if an announcement is not made.
    ///
    private var didReceiveShouldChange = false
    ///
    /// Hold off resetting `didReceiveShouldChange` until announcement is made, at which point it will be reset.
    ///
    private var isPendingAnnounceError = false

    #if DEBUG
    var onWillAnnounceError: ((String) -> Void)?
    var onDidAnnounceError: ((String) -> Void)?
    #endif

    // MARK: - Public

    /// Text Field Return Key Type
    public var returnKeyType: UIReturnKeyType {
        get {
            textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }

    /// Text Field Delegate
    public weak var delegate: GlassTextFieldDelegate?

    /// Text Field Content Type
    public var textContentType: UITextContentType {
        get {
            textField.textContentType
        }
        set {
            textField.textContentType = newValue
        }
    }

    /// Text input into the text field
    open var text: String? {
        get {
            return textField.text
        }
        set {
            // update error status when changing text programmatically
            textField.text = formatter?.execute(newValue).output ?? newValue
            textEditingDidChange()
            textEditingDidEnd()
        }
    }

    /// Text for the top title label - also displays as the placeholder when unfocused
    open var titleText: String? {
        didSet {
            titleLabel.text = titleText

            // In the context of GlassTextField, force the titleLabel to not represent itself to the
            // screen reader. The text field will provide its own accessibility description. We set
            // this flag after every time text is updated because GlassLabel _enables_ this flag when
            // its text is updated.
            titleLabel.isAccessibilityElement = false
            setTextFieldAccessibilityDescription()
        }
    }

    /// Text field placeholder text, appears when field is focused and text is empty
    open var placeholderText: String? {
        didSet {
            var placeholder = placeholderText ?? ""
            // When any text is entered, remove any extra hint help suffix from field label
            for suffix in ["*", "(required)", "(Required)"] {
                if placeholder.hasSuffix(suffix) {
                    placeholder = String(placeholder.dropLast(suffix.count))
                    break
                }
            }
            setPlaceholderProperties()
            setTextFieldAccessibilityDescription()
        }
    }

    /// Right aligned icon button
    var rightIconButton: UIButton!

    /// Don't show the right icon button without an icon to show
    private var canShowRightIconButton: Bool {
        return rightIcon != nil
    }

    /// Helper text to give context to expected input in the text field, appears below the divider
    open var hintText: String? {
        didSet {
            hintLabel.text = hintText
            updateHintLabel()
        }
    }

    public enum SecureTextEntryStyle: Equatable {
        case secure(showToggle: Bool), insecure
    }

    /// Set to `secure` to mask user input characters in the text field
    /// Use for any password field or any other sensitive information
    public var secureEntryStyle: SecureTextEntryStyle = .insecure {
        didSet {
            switch secureEntryStyle {
            case .secure(let showToggle):
                textField.isSecureTextEntry = true
                securityEntryToggleButton.isHidden = !showToggle
            case .insecure:
                textField.isSecureTextEntry = false
                securityEntryToggleButton.isHidden = true
            }
            setupConstraints()
        }
    }

    /// Set to true to mask user input characters in the text field
    /// Use for any password field or any other sensitive information
    public var isSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry

            securityEntryToggleButton.isHidden = !isSecureTextEntry
            setupConstraints()
        }
    }

    /// Title label should animate when text field state changes
    open var shouldAnimateTitleLabel = true

    /// Field should be validated to show errors as each character is typed
    open var shouldValidateEachTextChange = false

    /// Field should show right success icon and change color to reflect success state.
    open var shouldShowSuccessState = false

    open weak var previousTextField: UIResponder? {
        didSet {
            accessoryToolbar.setEnabled(previousTextField != nil, button: .prev)
        }
    }
    open weak var nextTextField: UIResponder? {
        didSet {
            accessoryToolbar.setEnabled(nextTextField != nil, button: .next)
        }
    }

    /// default validation: true if not empty
    open var validationBlock: ((String) -> String?)?

    /// The text that gets displayed on error label
    public var errorMessage: String? {
        didSet {
            if errorMessage != oldValue {
                invalidateIntrinsicContentSize()
                updateComponentColors()
                updateHintLabel()
                setTextFieldAccessibilityDescription()
            }
        }
    }

    /// Called specifically when text is auto-filled
    open var textAutofilled: ((GlassTextField) -> Void)?

    /// Called when text changes in the text field
    open var textDidChange: ((GlassTextField) -> Void)?

    /// Called when editing begins in the text field
    open var editingDidBegin: ((GlassTextField) -> Void)?

    /// Called when editing ends in the text field
    open var editingDidEnd: ((GlassTextField) -> Void)?

    /// True if and only if input is evaluated to be valid.
    /// Empty input should not be included, as this triggers the Success state.
    open var isInputValid: Bool = false {
        didSet {
            if validationBlock != nil {
                updateComponentColors()
                updateHintLabel()
                updateRightSuccessIconView()
            }
        }
    }

    /// Bool to show accessory toolbar over keyboard with "< >   Done"
    open var showAccessoryToolbar: Bool = true {
        didSet {
            if showAccessoryToolbar {
                textField.inputAccessoryView = accessoryToolbar
            } else {
                textField.inputAccessoryView = nil
            }
        }
    }

    /// Bool to show "Black" titleLabel, leftIconImageView and separatorView
    /// when textField is not first responder
    open var boldAttributes: Bool = false {
        didSet {
            titleLabel.textColor = boldAttributes ? GlassColor.gray200.uiColor : titleColor.uiColor
            leftIconImageView.tintColor = boldAttributes ? GlassColor.gray200.uiColor : leftIconColor?.uiColor
            separatorView.dividerColor = boldAttributes ? GlassColor.gray200 : separatorColor
        }
    }

    public var leftIcon: GlassIcon? {
        didSet {
            addIconView(icon: leftIcon)
        }
    }

    public var rightIcon: GlassIcon? {
        didSet {
            rightIconButton.setBackgroundImage(rightIcon?.imageSize16()?.withTintColor(rightIconColor.uiColor),
                                               for: .normal)
            rightIconButton.isHidden = !canShowRightIconButton
            rightIconButton.accessibilityTraits = [.button]
            rightIconButton.accessibilityLabel = rightIconAccessibilityLabel ?? rightIcon?.iconAccessibilityLabel
            setupConstraints()
        }
    }

    public var rightIconAction: (() -> Void)? {
        didSet {
            rightIconButton.isUserInteractionEnabled = rightIconAction != nil
        }
    }

    /// Sets the accessibility label on the right icon
    public var rightIconAccessibilityLabel: String? {
        didSet {
            rightIconButton?.accessibilityLabel = rightIconAccessibilityLabel
        }
    }

    /// Sets the accessibility hint on the right icon
    public var rightIconAccessibilityHint: String? {
        didSet {
            rightIconButton?.accessibilityHint = rightIconAccessibilityHint
        }
    }

    /// Sets the isAccessibilityElement of the right icon
    public var rightIconIsAccessibilityElement: Bool = true {
        didSet {
            rightIconButton.isAccessibilityElement = rightIconIsAccessibilityElement
        }
    }

    /// Sets the accessibility label on the right delete button
    public var rightDeleteIconButtonAccessibilityLabel: String? {
        didSet {
            rightDeleteIconButton.accessibilityLabel = rightDeleteIconButtonAccessibilityLabel
        }
    }

    /// Show the right icon button if an icon to show after setting the text
    public var showRightIconButton: Bool = false {
        didSet {
            if canShowRightIconButton {
                rightDeleteIconButton.isHidden = true
                // NOTE: This needs to get the main thread or it won't show the button
                DispatchQueue.main.async { [weak self] in
                    self?.rightIconButton.isHidden = false
                }
            }
        }
    }

    /// Update additional accessibilityHint text so voice over can read
    public var textFieldAccessibilityHint: String? {
        get {
            return textField.accessibilityHint
        }
        set {
            _textFieldAccessibilityHint = newValue
            textField.accessibilityHint = newValue
        }
    }

    /// Keyboard uses custom toolbar if `customAccessoryToolbar` assigned
    /// Alternately use `setCustomAccessoryToolbar` method to assign specific actions on next, prev and done
    @objc open var customAccessoryToolbar: GlassAccessoryToolbar? {
        didSet {
            guard let toolbar = customAccessoryToolbar else { return }
            accessoryToolbar = toolbar
            showAccessoryToolbar = true
        }
    }

    // MARK: - Text Field behavior

    /// Controls autocapitalization behavior for a text field.
    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }

    /// Controls keyboard autocorrection behavior for a text field.
    public var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }

    /// Constant that specify text alignment.
    public var textAlignment: NSTextAlignment {
        get {
            textField.textAlignment
        }
        set {
            textField.textAlignment = newValue
        }
    }

    /// Controls the annotation of misspelled words for the text field.
    public var spellCheckingType: UITextSpellCheckingType {
        get {
            return textField.spellCheckingType
        }
        set {
            textField.spellCheckingType = newValue
        }
    }

    /// Controls the keyboard type of the text field.
    public var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
            if textField.keyboardType == .emailAddress {
                textField.autocorrectionType = .no
            }
        }
    }

    // This is used if `isRequired` is explicitly set, otherwise
    // `isRequired` will be derived from the textfield's text
    private var _isRequired: Bool?
    /// Set to make this textfield required or not
    /// If never set, `isRequired` will be derived from the textfield's text
    public var isRequired: Bool {
        get {
            if let _isRequired = _isRequired {
                return _isRequired
            }

            return titleText?.hasSuffix("*") ?? false
        }
        set {
            _isRequired = newValue
            setTextFieldAccessibilityDescription()
        }
    }

    /// Whether or not the text field contains PII
    public var containsPII: Bool = false

    // MARK: - Layout - Anchor

    open override var lastBaselineAnchor: NSLayoutYAxisAnchor {
        separatorView.bottomAnchor
    }

    // MARK: - Init Methods

    override public convenience init(frame: CGRect) {
        self.init(frame: frame, observer: NotificationCenter.default)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(observer: NotificationCenter.default)
    }

    init(frame: CGRect,
         observer: GlassPIINotificationObserver)
    {
        super.init(frame: frame)
        commonInit(observer: observer)
    }

    //swiftlint:disable function_body_length
    fileprivate func commonInit(observer: GlassPIINotificationObserver) {
        textField.delegate = self

        addAutoLayoutSubview(textField)

        separatorContainer = UIView()
        addAutoLayoutSubview(separatorContainer)
        separatorView = GlassDivider()
        separatorView.dividerColor = separatorColor
        separatorView.layer.cornerRadius = 2.0
        separatorView.clipsToBounds = true
        separatorContainer.addAutoLayoutSubview(separatorView)
        focusedSeparatorViewTopConstraint = separatorView.topAnchor.constraint(equalTo: separatorContainer.topAnchor)
        unfocusedSeparatorViewTopConstraint = separatorView.topAnchor.constraint(
            equalTo: separatorContainer.topAnchor,
            constant: 1.0
        )
        focusedSeparatorViewTopConstraint.isActive = false

        createTitleLabel()

        hintLabel = GlassLabel(style: .captionRegular)
        hintLabel.numberOfLines = 2
        hintLabel.lineBreakMode = .byWordWrapping
        hintLabel.lineBreakStrategy = []
        addAutoLayoutSubview(hintLabel)

        if leftIconColor != nil {
            leftIconImageView = UIImageView(image: leftIcon?.imageSize24()?.withRenderingMode(.alwaysTemplate))
        } else {
            leftIconImageView = UIImageView(image: leftIcon?.imageSize24())
        }
        leftIconImageView.tintColor = leftIconColor?.uiColor
        leftIconImageView.alpha = leftIconAlpha
        addAutoLayoutSubview(leftIconImageView)

        let iconButton = GlassIconButton()
        iconButton.iconViewDimension = GlassSpacing.mediumSmall
        rightIconButton = iconButton
        rightIconButton.addTarget(self,
                                  action: #selector(GlassTextField.rightIconButtonTapped),
                                  for: .touchUpInside)
        rightIconButton.isHidden = true
        rightIconButton.clipsToBounds = false
        rightIconButton
            .publisher(for: \.isHidden)
            .sink(receiveValue: { [weak self] isHidden in
                self?.rightIconVisibilityDidChange(isHidden: isHidden)
            }).store(in: &tasks)

        addAutoLayoutSubview(rightIconButton)

        rightDeleteIconButton = GlassIconButton(icon: .close)
        rightDeleteIconButton.iconViewDimension = GlassSpacing.mediumSmall
        rightDeleteIconButton.addTarget(self, action: #selector(GlassTextField.clearText), for: .touchUpInside)
        rightDeleteIconButton.isHidden = true
        rightDeleteIconButton.customEnabledBackgroundColor = GlassColor.gray100
        addAutoLayoutSubview(rightDeleteIconButton)

        let successImage = successIcon?.imageSize24()
        rightSuccessIconView = UIImageView(image: successImage?.withTintColor(GlassColor.green100.uiColor))
        rightSuccessIconView.isHidden = true
        addAutoLayoutSubview(rightSuccessIconView)

        securityEntryToggleButton = GlassLinkButton()
        securityEntryToggleButton.setTitle("Show".localize(), for: .normal)
        securityEntryToggleButton.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)
        addAutoLayoutSubview(securityEntryToggleButton)

        statusIconView = UIImageView()
        addAutoLayoutSubview(statusIconView)

        setupConstraints()
        setEditTextObserver()
        errorMessage = nil

        assignAccessibilityIdentifiers()

        accessibilityElements = [textField,
                                 rightDeleteIconButton,
                                 securityEntryToggleButton].compactMap { $0 }

        setupNotificationObservers(observer: observer)
    }
    //swiftlint:enable function_body_length

    @objc func clearText() {
        textField.text = ""
        textEditingDidChange()
        validateTextField()
        updateComponentColors()
        updateHintLabel()
        rightIconAction?()
        DispatchQueue.main.async { [weak self] in
            self?.rightDeleteIconButton.isHidden = true
        }
    }

    /// Determines if the `clearValidation` function should be automatically called when the user edits the text or
    /// focus on the text field.
    ///
    /// Defaults to `true`.
    ///
    /// You can rely on this property and avoid code like this:
    /// ````
    /// textField.textDidChange = { $0.clearValidation() }
    /// textField.editingDidBegin = { $0.clearValidation() }
    /// ````
    public var autoClearValidation = true

    private func clearValidationIfRequired() {
        guard autoClearValidation,
              errorMessage != nil else {
            return
        }
        clearValidation()
    }

    /// Removes error message and resets validation
    public func clearValidation() {
        errorMessage = nil
        isInputValid = false
    }

    open func addIconView(icon: GlassIcon?) {
        let isExistingImage = leftIconImageView.image != nil
        let isAddingImage = icon != nil

        if leftIconColor != nil {
            leftIconImageView.image = icon?.imageSize24()?.withRenderingMode(.alwaysTemplate)
        } else {
            leftIconImageView.image = icon?.imageSize24()
        }
        leftIconImageView.tintColor = leftIconColor?.uiColor
        leftIconImageView.alpha = leftIconAlpha
        if isAddingImage != isExistingImage {
            setupConstraints()
        }
    }

    public func configure(_ configuration: GlassTextFieldConfiguration) {
        placeholderText = configuration.placeholderText
        text = configuration.text
        titleText = configuration.titleText
        hintText = configuration.hintText
        leftIcon = configuration.leftIcon
        rightIcon = configuration.rightIcon
        rightIconAction = configuration.rightIconAction
        validationBlock = configuration.validationBlock
        shouldAnimateTitleLabel = configuration.shouldAnimateTitleLabel ?? true
        shouldShowSuccessState = configuration.shouldShowSuccessState ?? false
        shouldValidateEachTextChange = configuration.shouldValidateEachTextChange ?? false
        autoClearValidation = configuration.autoClearValidation ?? true
        nextTextField = configuration.next
        previousTextField = configuration.previous

        configureSecureEntry(configuration)

        rightDeleteIconButton.accessibilityLabel = [DefaultText.clearFieldAccessibilityLabel, titleText]
            .compactMap { ($0 ?? "").isEmpty ? nil : $0 }
            .joined(separator: " ")
    }

    /// This gives priority to the `isSecureEntry` option - if it is set, it is used. Otherwise,
    /// use the `secureEntryStyle` or default to `isSecureTextEntry = false`.
    private func configureSecureEntry(_ configuration: GlassTextFieldConfiguration) {
        if let isSecureTextEntry = configuration.isSecureEntry {
            self.isSecureTextEntry = isSecureTextEntry
        } else if let secureEntryStyle = configuration.secureEntryStyle {
            self.secureEntryStyle = secureEntryStyle
        } else {
            self.isSecureTextEntry = false
        }
    }

    // MARK: - Custom Components

    fileprivate func setPlaceholderProperties() {
        guard let hint = placeholderText else { return }
        let attributes = [
            NSAttributedString.Key.foregroundColor: GlassColor.gray100.uiColor,
            NSAttributedString.Key.font: GlassFont.body1().uiFont
        ]
        textField.attributedPlaceholder = NSAttributedString(string: hint, attributes: attributes)
    }

    // swiftlint:disable function_body_length
    fileprivate func setupConstraints() {
        removeConstraints(constraints)
        var constraints: [NSLayoutConstraint] = []

        // Title Label Constraints
        configureTitleLabel(animated: false)

        // Text Field Constraints
        constraints.append(contentsOf: [
            textField.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.small),
            textField.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall)
        ])

        if leftIcon == nil {
            constraints.append(textField.leadingAnchor.constraint(equalTo: leadingAnchor))
        } else {
            constraints.append(contentsOf: [
                textField.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor,
                                                   constant: GlassSpacing.xSmall),
                leftIconImageView.widthAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall),
                leftIconImageView.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall)
            ])

            // Left Icon Image View Constraints
            constraints.append(contentsOf: [
                leftIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                leftIconImageView.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                                          constant: -GlassSpacing.small)
            ])
        }

        // Right Icon Button Constraints
        constraints.append(contentsOf: [
            rightIconButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightIconButton.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                                    constant: -GlassSpacing.small),
            rightIconButton.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall),
            rightIconButton.widthAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall)
        ])

        constraints.append(
            textField.trailingAnchor.constraint(equalTo: rightDeleteIconButton.leadingAnchor,
                                                constant: -GlassSpacing.small)
        )

        // Toggle Secure Entry Button
        constraints.append(contentsOf: [
            securityEntryToggleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            securityEntryToggleButton.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                                            constant: -GlassSpacing.small)
        ])

        // Separator Constraints
        constraints.append(contentsOf: [
            separatorContainer.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: GlassSpacing.xSmall),
            separatorContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorContainer.heightAnchor.constraint(equalToConstant: selectedSeparatorWeight)
        ])

        constraints.append(contentsOf: [
            separatorView.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: separatorContainer.bottomAnchor)
        ])

        // Hint Label Constraints
        constraints.append(contentsOf: [
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hintLabel.topAnchor.constraint(equalTo: separatorContainer.bottomAnchor, constant: GlassSpacing.xxSmall),
            hintLabel.trailingAnchor.constraint(equalTo: statusIconView.leadingAnchor,
                                                constant: -GlassSpacing.xxSmall),
            hintLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),

            statusIconView.heightAnchor.constraint(equalToConstant: GlassSpacing.small),
            statusIconView.widthAnchor.constraint(equalToConstant: GlassSpacing.small),
            statusIconView.topAnchor.constraint(equalTo: hintLabel.topAnchor),
            statusIconView.trailingAnchor.constraint(lessThanOrEqualTo: separatorContainer.trailingAnchor)
        ])

        constraints.append(contentsOf: [
            rightDeleteIconButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightDeleteIconButton.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                                          constant: -GlassSpacing.small)
        ])

        constraints.append(contentsOf: [
            rightSuccessIconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightSuccessIconView.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                                         constant: -GlassSpacing.small)
        ])

        constraints.append(heightAnchor.constraint(greaterThanOrEqualToConstant: GlassTextField.defaultHeight))

        NSLayoutConstraint.activate(constraints)
        setNeedsLayout()
    }

    func createTitleLabel() {
        titleLabel = GlassLabel(style: .captionRegular)
        titleLabel.textColor = titleColor.uiColor
        addAutoLayoutSubview(titleLabel)

        titleLabelAsTitleConstraints = [
            titleLabel.bottomAnchor.constraint(equalTo: textField.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: GlassSpacing.small)
        ]

        titleLabelAsTitleConstraints.forEach({ $0.isActive = false })

        titleLabelAsPlaceholderConstraints = [
            titleLabel.bottomAnchor.constraint(equalTo: separatorContainer.topAnchor,
                                               constant: -GlassSpacing.small),
            titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: GlassSpacing.mediumSmall)
        ]
    }

    func configureTitleLabel(animated: Bool? = nil) {
        let animated = animated ?? shouldAnimateTitleLabel
        if titleText != nil && placeholderText == nil {
            UIView.animate(withDuration: animated ? 0.15 : 0.0,
                           animations: { [weak self] in
                            guard let self = self else { return }
                            if self.textField.isFirstResponder || self.text != "" {
                                // Title label should be positioned above the text field
                                self.titleLabelAsPlaceholderConstraints.deactivate()
                                self.titleLabelAsTitleConstraints.activate()
                                self.textField.placeholder = self.placeholderText
                                self.textField.alpha = 1.0

                                self.titleLabel.font = GlassFont.captionRegular().uiFont
                                self.titleLabel.textColor = self.titleColor.uiColor

                            } else {
                                self.titleLabelAsTitleConstraints.deactivate()
                                self.titleLabelAsPlaceholderConstraints.activate()
                                self.textField.alpha = 0.1

                                self.titleLabel.font = GlassFont.body1().uiFont
                                self.titleLabel.textColor = self.titleColor.uiColor
                            }
                            if animated {
                                self.layoutIfNeeded()
                            }

                }, completion: { [weak self] (_) in
                    guard let self = self else { return }
                    if !(self.textField.isFirstResponder || self.text != "") {
                        self.textField.placeholder = ""
                    }
            })
        } else {
            titleLabelAsTitleConstraints.activate()
            titleLabelAsPlaceholderConstraints.deactivate()
        }
    }

    func configureSeparatorThickness() {
        if textField.isFirstResponder {
            unfocusedSeparatorViewTopConstraint.isActive = false
            focusedSeparatorViewTopConstraint.isActive = true
        } else {
            focusedSeparatorViewTopConstraint.isActive = false
            unfocusedSeparatorViewTopConstraint.isActive = true
        }
        setNeedsLayout()
    }

    @objc func toggleSecureText() {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        textField.isSecureTextEntry ?
            securityEntryToggleButton?.setTitle("Show".localize(), for: .normal) :
            securityEntryToggleButton?.setTitle("Hide".localize(), for: .normal)
    }

    @objc func rightIconButtonTapped() {
        rightIconAction?()
    }

    // MARK: Accessibility

    /// Update accessibility so voice over is helpful
    open func setTextFieldAccessibilityDescription() {
        var titleText = self.titleText
        if var requiredTitle = titleText, isRequired {
            // Only drop the last character (*) if `isRequired` was computed to `true`
            requiredTitle.removeAll { $0 == "*" }
            requiredTitle += " (required)"
            titleText = requiredTitle
        }

        if let title = titleText, title.isEmpty {
            titleText = placeholderText
        }

        if let errorMessage = self.errorMessage,
            !errorMessage.isEmpty
        {
            titleText = titleText.flatMap { "\($0). \(errorMessage)" } ?? errorMessage

            isPendingAnnounceError = true

            #if DEBUG
            onWillAnnounceError?(errorMessage)
            #endif

            //
            // Using a hard coded delay to make implementation simple for when to
            // make announcement.  Value randomly choosen and tested on iPhone SE
            // 2020 so that announcement is made after announcement of what key
            // is tapped.
            //
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                defer {
                    self.didReceiveShouldChange = false
                    self.isPendingAnnounceError = false
                }

                guard self.textField.isEditing, self.didReceiveShouldChange else { return }

                UIAccessibility.post(notification: .announcement, argument: errorMessage)

                #if DEBUG
                self.onDidAnnounceError?(errorMessage)
                #endif
            }
        } else if !isPendingAnnounceError {
            didReceiveShouldChange = false
        }

        textField.accessibilityLabel = titleText
    }

    // MARK: - Observer

    fileprivate func setEditTextObserver() {
        textField.addTarget(self, action: #selector(GlassTextField.textEditingDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(GlassTextField.textEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(GlassTextField.textEditingDidEnd), for: .editingDidEnd)
    }

    @objc func textEditingDidBegin() {
        if let text = textField.text, !text.isEmpty,
            !isSecureTextEntry {
            rightDeleteIconButton.isHidden = false
            // NOTE: This needs to get the main thread or it won't hide the button
            DispatchQueue.main.async { [weak self] in
                self?.rightIconButton.isHidden = true
            }
        }
        separatorView.dividerColor = separatorColor
        configureTitleLabel()
        configureSeparatorThickness()
        updateComponentColors()
        updateRightSuccessIconView()
        clearValidationIfRequired()
        editingDidBegin?(self)
    }

    @objc func textEditingDidEnd() {
        if !isSecureTextEntry {
            rightDeleteIconButton.isHidden = true
            rightIconButton.isHidden = !canShowRightIconButton
        }
        separatorView.dividerColor = separatorColor
        configureTitleLabel()
        updateComponentColors()
        configureSeparatorThickness()
        updateRightSuccessIconView()
        editingDidEnd?(self)
    }

    /// Also called after changing text programmatically in order to update hint labels
    @objc func textEditingDidChange() {
        if let text = textField.text, !text.isEmpty,
            !isSecureTextEntry {
            rightDeleteIconButton.isHidden = false
            // NOTE: This needs to get the main thread or it won't hide the button
            DispatchQueue.main.async { [weak self] in
                self?.rightIconButton.isHidden = true
            }
        } else if let text = textField.text, text.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.rightDeleteIconButton.isHidden = true
            }
        }

        if shouldValidateEachTextChange || text == nil || text!.isEmpty {
            validateTextField()
        } else {
            clearValidationIfRequired()
        }
        textDidChange?(self)
    }

    /// Returns true if text field input is valid
    @discardableResult public func validateTextField() -> Bool {
        let unwrappedText = text ?? ""

        // Suppress errors on a field being edited, unless it's empty or we're validating each character
        if isFirstResponder && (!shouldValidateEachTextChange || unwrappedText.isEmpty) {
            errorMessage = nil
            isInputValid = false
            return true
        }

        if let error = validationBlock?(unwrappedText) {
            errorMessage = error
            isInputValid = false
            return false
        } else if unwrappedText.isEmpty {
            errorMessage = nil
            isInputValid = false
            return true
        } else {
            isInputValid = validationBlock != nil
            errorMessage = nil
            return true
        }
    }

    @discardableResult open override func resignFirstResponder() -> Bool {
        let superResignResponder = super.resignFirstResponder()
        validateTextField()
        updateComponentColors()
        textField.resignFirstResponder()
        return superResignResponder
    }

    @discardableResult open override func becomeFirstResponder() -> Bool {
        let superBecomeFirstResponder = super.becomeFirstResponder()
        if superBecomeFirstResponder {
            errorMessage = nil
            validateTextField() // Clear errors when editing begins
            updateComponentColors()
        }
        textField.becomeFirstResponder()
        return superBecomeFirstResponder
    }

    private func rightIconVisibilityDidChange(isHidden: Bool) {
        accessibilityElements?.removeAll(where: { rightIconButton === $0 as AnyObject })
        guard !isHidden else { return }
        guard canShowRightIconButton else { return }

        if let button = rightIconButton {
            accessibilityElements?.append(button)
        }
    }

    // MARK: - Helper methods

    /// This also colors the separator to match the placeholderText
    fileprivate func updateComponentColors() {
        hintLabel.textColor = hintColor.uiColor
        titleLabel.textColor = titleColor.uiColor
        separatorView.dividerColor = separatorColor
        leftIconImageView.tintColor = leftIconColor?.uiColor
        leftIconImageView.alpha = leftIconAlpha
        rightIconButton.setBackgroundImage(rightIcon?.imageSize16()?.withTintColor(rightIconColor.uiColor),
                                           for: .normal)
    }

    fileprivate func updateHintLabel() {
        var hint: String?

        if errorMessage != nil {
            hintLabel.text = errorMessage
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
            hint = hintText
        }

        textField.accessibilityHint = _textFieldAccessibilityHint ?? hint
    }

    fileprivate func updateRightSuccessIconView() {
        if isInputValid && !textField.isFirstResponder &&
            shouldShowSuccessState && !isSecureTextEntry {
            rightSuccessIconView.isHidden = false
            rightIconButton?.isHidden = true
        } else {
            rightSuccessIconView.isHidden = true
            rightIconButton?.isHidden = !canShowRightIconButton
        }
    }

    // MARK: - Text Field Drawing Methods

    fileprivate let titleLabelHeight: CGFloat = GlassSpacing.small

    @objc func doneEditing() {
        _ = resignFirstResponder()
    }

    @objc func gotoPreviousTextField() {
        if let prevfield = previousTextField {
            _ = prevfield.becomeFirstResponder()
        }
    }

    @objc func gotoNextTextField() {
        if let nextfield = nextTextField {
            _ = nextfield.becomeFirstResponder()
        }
    }

    // MARK: - Obfuscation

    // Container variable for the text that is currently obfuscated
    private var obfuscatedText: String?

    @objc
    public func obfuscatePII() {
        guard containsPII
        else {
            return
        }

        obfuscatedText = text
        textField.text = nil
    }

    @objc
    public func deobfuscatePII() {
        guard containsPII,
              let obfuscatedText = self.obfuscatedText
        else {
            return
        }

        textField.text = obfuscatedText
        self.obfuscatedText = nil
    }
}

public struct GlassTextFieldConfiguration {
    public var leftIcon: GlassIcon?
    public var rightIcon: GlassIcon?
    public var rightIconAction: (() -> Void)?
    public var placeholderText: String?
    public var text: String?
    public var titleText: String?
    public var hintText: String?
    public var validationBlock: ((String) -> String?)?
    public var shouldAnimateTitleLabel: Bool?
    public var shouldValidateEachTextChange: Bool?
    public var shouldShowSuccessState: Bool?
    public var isSecureEntry: Bool?
    public var secureEntryStyle: GlassTextField.SecureTextEntryStyle?
    public var autoClearValidation: Bool?
    public var next: UIResponder?
    public var previous: UIResponder?

    public init(leftIcon: GlassIcon? = nil,
                rightIcon: GlassIcon? = nil,
                rightIconAction: (() -> Void)? = nil,
                placeholderText: String? = nil,
                text: String? = nil,
                titleText: String? = nil,
                hintText: String? = nil,
                validationBlock: ((String) -> String?)? = nil,
                shouldAnimateTitleLabel: Bool? = true,
                shouldValidateEachTextChange: Bool? = nil,
                shouldShowSuccessState: Bool? = nil,
                isSecureEntry: Bool? = nil,
                secureEntryStyle: GlassTextField.SecureTextEntryStyle? = nil,
                autoClearValidation: Bool? = nil,
                next: UIResponder? = nil,
                previous: UIResponder? = nil) {
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.rightIconAction = rightIconAction
        self.placeholderText = placeholderText
        self.text = text
        self.titleText = titleText
        self.hintText = hintText
        self.validationBlock = validationBlock
        self.shouldAnimateTitleLabel = shouldAnimateTitleLabel
        self.shouldValidateEachTextChange = shouldValidateEachTextChange
        self.shouldShowSuccessState = shouldShowSuccessState
        self.isSecureEntry = isSecureEntry
        self.secureEntryStyle = secureEntryStyle
        self.autoClearValidation = autoClearValidation
        self.next = next
        self.previous = previous
    }
}

extension GlassTextField: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        validateTextField()
        delegate?.textFieldDidEndEditing?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        validateTextField()
        delegate?.textFieldDidEndEditing?(textField)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        didReceiveShouldChange = true

        // Autofill special case. No formatting will be applied for auto-filled text.
        if range.location == 0, range.length == 0, string == " " {
            textAutofilled?(self)
            return true
        }

        // If a formatter is set, use the transform. Otherwise, use UITextfield's default behavior
        guard let formatter = formatter else {
            return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        }

        // Shouldn't happen but has been observed (after pasting invalid characters followed by shake to undo)
        let previousText = textField.text
        guard Range(range, in: previousText ?? "") != nil else {
            return false
        }

        // What the string will be if we are to replace characters in given range
        let newText = ((previousText ?? "") as NSString).replacingCharacters(in: range, with: string)

        // Make sure to get the raw version of that text first by calling 'revert' on the formatter
        let rawText = formatter.revert(newText)

        // Transform the rawText
        let result = formatter.execute(rawText)

        // Set the output as the textfield's display text
        textField.text = result.output
//        if let cursorIndex = cursorPositioning?.cursorIndex(oldString: previousText,
//                                                            replacingString: string,
//                                                            range: range,
//                                                            newString: textField.text),
//           let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: cursorIndex) {
//            textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
//        }

        textDidChange?(self)

        return false
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.textFieldDidChangeSelection?(textField)
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldClear?(textField) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn?(textField) ?? true
    }
}

extension GlassTextField {

    /// Checks whether the `GlassTextField` is composed by the `textField` or not.
    /// This function is useful when you need to apply different rules to multiple textFields on
    /// a `textField(shouldChangeCharactersIn: replacementString:)` function.
    /// - Parameter textField: the text field which we want to check if it's contained inside the `GlassTextField`
    /// - Returns: true if the `GlassTextField contains the `textField`
    func contains(textField: UITextField) -> Bool {
        self.textField === textField
    }
}

// swiftlint:enable file_length

#if DEBUG
extension GlassTextField {
    var testHooks: TestHooks {
        .init(target: self)
    }

    struct TestHooks {
        let target: GlassTextField

        var textField: UITextField {
            target.textField
        }

        var separatorView: GlassDivider {
            target.separatorView
        }

        var rightIconButton: UIButton {
            target.rightIconButton
        }

        var securityEntryToggleButton: UIButton {
            target.securityEntryToggleButton
        }

        var titleLabel: GlassLabel {
            target.titleLabel
        }

        var leftIconImageView: UIImageView {
            target.leftIconImageView
        }

        var text: String? {
            target.text
        }

        var obfuscatedText: String? {
            target.obfuscatedText
        }

        var didReceiveShouldChange: Bool {
            get {
                target.didReceiveShouldChange
            }

            set {
                target.didReceiveShouldChange = newValue
            }
        }

        var isPendingAnnounceError: Bool {
            get {
                target.isPendingAnnounceError
            }

            set {
                target.isPendingAnnounceError = newValue
            }
        }

        func notifyOnDidAnnounceError(_ callback: ((String) -> Void)?) {
            target.onDidAnnounceError = callback
        }

        func notifyOnWillAnnounceError(_ callback: ((String) -> Void)?) {
            target.onWillAnnounceError = callback
        }
    }
}
#endif


/// Transforms allow you to easily transform from any input Type to any output Type, while keeping track of the
/// raw input, updated input and output
public protocol TransformType {
    associatedtype Input
    associatedtype Output

    // Required
    /// Transform from Input to Output
    func transform(_ input: Input?) -> Output?

    /// Revert Output to Input
    func revert(_ output: Output?) -> Input?

    // Optional
    /// Optionally update the input before transforming it
    func updateInput(_ input: Input?) -> Input?
}

// Transform Protocol extension
public extension Transform {
    func execute(_ input: Input?) -> TransformResult<Input, Output> {
        let rawInput = input
        let updatedInput = updateInput(input)
        let output = transform(updatedInput)

        return TransformResult<Input, Output>(
            rawInput: rawInput,
            updatedInput: updatedInput,
            output: output
        )
    }
}

open class Transform<Input, Output>: TransformType {
    public init() { }

    open func updateInput(_ input: Input?) -> Input? {
        input
    }

    open func transform(_ input: Input?) -> Output? {
        input as? Output
    }

    open func revert(_ output: Output?) -> Input? {
        output as? Input
    }
}

/// The result from transforming input into output. This includes raw input, updated input and the output
public struct TransformResult<Input, Output> {
    public let rawInput: Input?
    public let updatedInput: Input?
    public let output: Output?
}
