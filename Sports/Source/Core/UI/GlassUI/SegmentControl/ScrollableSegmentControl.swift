/*
MIT License

Copyright (c) 2016 Goce Petrovski @GocePetrovski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//
//  ScrollableSegmentedControl.swift
//  ScrollableSegmentedControl
//
//  Created by Goce Petrovski on 10/11/16.
//  Copyright © 2017 Pomarium. All rights reserved.
//

// swiftlint:disable line_length

import UIKit

@objc public protocol GlassSegmentedControlDelegate: AnyObject {
    @objc func fetchImage(at index: Int, completion: @escaping(UIImage?, URL?) -> Void)
}

@objc
public enum ScrollableSegmentedControlSegmentStyle: Int {
    case textOnly, imageOnly, imageOnTop, imageOnLeft
}

/**
 A ScrollableSegmentedControl object is horizontaly scrollable control made of multiple segments, each segment functioning as discrete button.
 */
@IBDesignable
open class ScrollableSegmentedControl: UIControl {
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate var collectionView:UICollectionView?
    private var collectionViewController:CollectionViewController?
    private var segmentsData = [SegmentData]()
    private var longestTextWidth:CGFloat = 125
    open weak var delegate: GlassSegmentedControlDelegate?

    open var showShadow: Bool

    open var hasDynamicSegmentSize: Bool = false

    private struct Constants {
        static let defaultSelectedIndex: Int = -1
    }

    @objc public var segmentStyle:ScrollableSegmentedControlSegmentStyle = .textOnly {
        didSet {
            if oldValue != segmentStyle {
                switch segmentStyle {
                case .textOnly:
                    collectionView?.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
                case .imageOnly:
                    collectionView?.register(ImageOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier)
                case .imageOnTop:
                    collectionView?.register(ImageOnTopSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier)
                case .imageOnLeft:
                    collectionView?.register(ImageOnLeftSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier)
                }

                let indexPath = collectionView?.indexPathsForSelectedItems?.last

                setNeedsLayout()
                flowLayout.invalidateLayout()
                reloadSegments()

                if indexPath != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                    })
                }

            }
        }
    }

    override open var tintColor: UIColor! {
        didSet {
            collectionView?.tintColor = tintColor
            reloadSegments()
        }
    }

    fileprivate var _segmentContentColor:UIColor?
    @objc public dynamic var segmentContentColor:UIColor? {
        get { return _segmentContentColor }
        set {
            _segmentContentColor = newValue
            reloadSegments()
        }
    }

    fileprivate var _selectedSegmentContentColor:UIColor?
    @objc public dynamic var selectedSegmentContentColor:UIColor? {
        get { return _selectedSegmentContentColor }
        set {
            _selectedSegmentContentColor = newValue
            reloadSegments()
        }
    }

    override public init(frame: CGRect) {
        showShadow = true
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    fileprivate var normalAttributes:[NSAttributedString.Key : Any]?
    fileprivate var highlightedAttributes:[NSAttributedString.Key : Any]?
    fileprivate var selectedAttributes:[NSAttributedString.Key : Any]?
    fileprivate var _titleAttributes:[UInt: [NSAttributedString.Key : Any]] = [UInt: [NSAttributedString.Key : Any]]()
    @objc public func setTitleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) {
        _titleAttributes[state.rawValue] = attributes

        normalAttributes = _titleAttributes[UIControl.State.normal.rawValue]
        highlightedAttributes = _titleAttributes[UIControl.State.highlighted.rawValue]
        selectedAttributes = _titleAttributes[UIControl.State.selected.rawValue]

        for segment in segmentsData {
            configureAttributedTitle(for: segment)

            if let title = segment.title {
                calculateLongestTextWidth(text: title)
            }
        }

        flowLayout.invalidateLayout()
        reloadSegments()
    }

    public func setNormalTextAttributes() {
        let textAttributes = (normalAttributes != nil)
            ? normalAttributes!
            : [NSAttributedString.Key.font: GlassFont.body2().uiFont,
               NSAttributedString.Key.foregroundColor: GlassColor.gray160.uiColor]

        setTitleTextAttributes(textAttributes, for: .normal)
    }

    private func configureAttributedTitle(for segment: SegmentData) {
        segment.normalAttributedTitle = nil
        segment.highlightedAttributedTitle = nil
        segment.selectedAttributedTitle = nil

        if let title = segment.title {
            if normalAttributes != nil {
                segment.normalAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
            }

            if highlightedAttributes != nil {
                segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
            } else {
                if selectedAttributes != nil {
                    segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }

            if selectedAttributes != nil {
                segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
            } else {
                if highlightedAttributes != nil {
                    segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
        }
    }

    @objc public func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key : Any]? {
        return _titleAttributes[state.rawValue]
    }

    // MARK: - Managing Segments

    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content and/or image from URL or content.
     */
    @objc public func insertSegment(withTitle title: String?,
                                    image: UIImage?,
                                    imageUrl: URL?,
                                    placeholderImage: UIImage?,
                                    withMode mode: UIImage.RenderingMode = .alwaysOriginal,
                                    at index: Int,
                                    accessibilityIdentifier: String? = nil) {

        let segment = SegmentData()
        segment.image = image?.withRenderingMode(mode)
        segment.imageInfo = (imageUrl, placeholderImage?.withRenderingMode(mode))
        segment.accessibilityIdentifier = accessibilityIdentifier
        segmentsData.insert(segment, at: index)

        if let str = title {
            segment.title = str
            calculateLongestTextWidth(text: str)
        }
        reloadSegments()
    }

    /**
     Removes all segments from the receiver.
     */
    @objc public func removeAllSegments(){
        segmentsData.removeAll()
        selectedSegmentIndex = Constants.defaultSelectedIndex
    }

    /**
     Removes segment at a specific position from the receiver.
     */
    @objc public func removeSegment(at segment: Int){
        let validRange = 0 ... segmentsData.count
        guard validRange ~= segment else {
            return
        }
        let selectedSegmentIndex = self.selectedSegmentIndex
        segmentsData.remove(at: segment)
        // Re-calculate selected segment index, in case selected segment was removed.
        self.selectedSegmentIndex = selectedSegmentIndex
        reloadSegments()
    }

    /**
     Returns the number of segments the receiver has.
     */
    @objc public var numberOfSegments: Int { return segmentsData.count }

    /**
     Returns the title of the specified segment.
     */
    @objc public func titleForSegment(at segment: Int) -> String? {
        if segmentsData.isEmpty {
            return nil
        }

        return safeSegmentData(forIndex: segment).title
    }

    /**
     The index number identifying the selected segment (that is, the last segment touched).

     Set this property to -1 to turn off the current selection.
     */
    @objc public var selectedSegmentIndex: Int = Constants.defaultSelectedIndex {
        didSet{
            if selectedSegmentIndex < Constants.defaultSelectedIndex {
                selectedSegmentIndex = Constants.defaultSelectedIndex
            } else if selectedSegmentIndex > segmentsData.count - 1 {
                selectedSegmentIndex = segmentsData.count - 1
            }

            if selectedSegmentIndex >= 0 {
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            } else {
                if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
                    collectionView?.deselectItem(at: indexPath, animated: true)
                }
            }

            if oldValue != selectedSegmentIndex {
                self.sendActions(for: .valueChanged)
            }
        }
    }

    /**
     The index number identifying the selected segment (that is, the last segment touched).
     Since selectedSegmentIndex triggers valueChanged, this can be used to select but not trigger value change.
     Helpful during automatic horizontal scrolling
     */

    /// Warning : - Do not use this value inplace of selectedSegmentIndex.
    /// Client must handle setting selectedSegmentIndex separetely
    @objc public var activeSegmentIndex: Int = Constants.defaultSelectedIndex {
        didSet {
            if activeSegmentIndex < Constants.defaultSelectedIndex {
                selectedSegmentIndex = Constants.defaultSelectedIndex
            } else if activeSegmentIndex > segmentsData.count - 1 {
                selectedSegmentIndex = segmentsData.count - 1
            }

            if activeSegmentIndex >= 0 {
                let indexPath = IndexPath(item: activeSegmentIndex,
                                          section: 0)
                collectionView?.selectItem(at: indexPath,
                                           animated: true,
                                           scrollPosition: .centeredHorizontally)
            }
        }
    }

    /**
     Configure if the selected segment should have underline. Default value is false.
     */
    @IBInspectable
    public var underlineSelected:Bool = false

    // MARK: - Layout management

    override open func layoutSubviews() {
        super.layoutSubviews()

        collectionView?.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        configureSegmentSize()

        flowLayout.invalidateLayout()

        reloadSegments()
    }

    // MARK: - Private

    fileprivate func configure() {
        clipsToBounds = true

        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView!.tag = 1
        collectionView!.tintColor = tintColor
        collectionView!.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
        collectionViewController = CollectionViewController(segmentedControl: self)
        collectionView!.dataSource = collectionViewController
        collectionView!.delegate = collectionViewController
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
    }

    fileprivate func configureSegmentSize() {
        let width:CGFloat

        switch segmentStyle {
        case .imageOnLeft:
            width = longestTextWidth + BaseSegmentCollectionViewCell.imageSize + BaseSegmentCollectionViewCell.imageToTextMargin * 2
        default:
            if collectionView!.frame.size.width > longestTextWidth * CGFloat(segmentsData.count) {
                width = collectionView!.frame.size.width / CGFloat(segmentsData.count)
            } else {
                width = longestTextWidth
            }
        }

        let itemSize = CGSize(width: width, height: frame.size.height)
        flowLayout.itemSize = itemSize
    }

    fileprivate func calculateLongestTextWidth(text:String) {
        longestTextWidth = max(calculateTextWidth(text), longestTextWidth)
        configureSegmentSize()
    }

    fileprivate func calculateTextWidth(_ text:String) -> CGFloat {
        let fontAttributes:[NSAttributedString.Key:Any]
        if normalAttributes != nil {
            fontAttributes = normalAttributes!
        } else if highlightedAttributes != nil {
            fontAttributes = highlightedAttributes!
        } else if selectedAttributes != nil {
            fontAttributes = selectedAttributes!
        } else {
            fontAttributes =  [.font: BaseSegmentCollectionViewCell.defaultFont]
        }

        let size = (text as NSString).size(withAttributes: fontAttributes)
        var textWidth: CGFloat = 0.0
        switch segmentStyle {
        case .imageOnTop:
            textWidth = 2.0 + size.width + ImageOnTopSegmentCollectionViewCell.cellPadding * 2
        default:
            textWidth = 2.0 + size.width + BaseSegmentCollectionViewCell.textPadding * (hasDynamicSegmentSize ? 4 : 2)
        }

        return textWidth
    }

    private func safeSegmentData(forIndex index:Int) -> SegmentData {
        let segmentData:SegmentData

        if index <= 0 {
            segmentData = segmentsData[0]
        } else if index >= segmentsData.count {
            segmentData = segmentsData[segmentsData.count - 1]
        } else {
            segmentData = segmentsData[index]
        }

        return segmentData
    }

    fileprivate func reloadSegments() {
        if let collectionView_ = collectionView {
            collectionView_.reloadData()
            if selectedSegmentIndex >= 0 && numberOfSegments > 0 {
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                collectionView_.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
    }

    /*
     Private internal classes to be used only by this class.
     */

    // MARK: - SegmentData

    final private class SegmentData {
        var title:String?
        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?
        var image:UIImage?
        var imageInfo: (imageUrl: URL?, placeholderImage: UIImage?)?
        var accessibilityIdentifier: String?
    }

    // MARK: - CollectionViewController

    /**
     A CollectionViewController is private inner class with main purpose to hide UICollectionView protocol conformances.
     */
    final private class CollectionViewController : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        static let textOnlyCellIdentifier = "textOnlyCellIdentifier"
        static let imageOnlyCellIdentifier = "imageOnlyCellIdentifier"
        static let imageOnTopCellIdentifier = "imageOnTopCellIdentifier"
        static let imageOnLeftCellIdentifier = "imageOnLeftCellIdentifier"

        private weak var segmentedControl: ScrollableSegmentedControl!

        init(segmentedControl:ScrollableSegmentedControl) {
            self.segmentedControl = segmentedControl
        }

        // UICollectionViewDataSource

        fileprivate func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

        fileprivate func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return segmentedControl.numberOfSegments
        }

        fileprivate func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let segmentCell:BaseSegmentCollectionViewCell
            let data = segmentedControl.segmentsData[indexPath.item]
            // swiftlint:disable force_cast
            switch segmentedControl.segmentStyle {
            case .textOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.textOnlyCellIdentifier, for: indexPath) as! TextOnlySegmentCollectionViewCell
                cell.titleLabel.text = data.title
                segmentCell = cell
            case .imageOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier, for: indexPath) as! ImageOnlySegmentCollectionViewCell
                cell.imageView.image = data.image
                cell.placeholderImage = data.imageInfo?.placeholderImage
                cell.imageUrl = data.imageInfo?.imageUrl
                segmentCell = cell
            case .imageOnTop:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier, for: indexPath) as! ImageOnTopSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                cell.placeholderImage = data.imageInfo?.placeholderImage
                cell.imageUrl = data.imageInfo?.imageUrl
                segmentCell = cell
            case .imageOnLeft:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier, for: indexPath) as! ImageOnLeftSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                cell.placeholderImage = data.imageInfo?.placeholderImage
                cell.imageUrl = data.imageInfo?.imageUrl
                segmentCell = cell
            }
            // swiftlint:enabled force_cast

            segmentCell.showUnderline = segmentedControl.underlineSelected
            if segmentedControl.underlineSelected {
                segmentCell.tintColor = segmentedControl.tintColor
            }

            segmentCell.contentColor = segmentedControl.segmentContentColor
            segmentCell.selectedContentColor = segmentedControl.selectedSegmentContentColor

            segmentCell.normalAttributedTitle = data.normalAttributedTitle
            segmentCell.highlightedAttributedTitle = data.highlightedAttributedTitle
            segmentCell.selectedAttributedTitle = data.selectedAttributedTitle

            segmentCell.isAccessibilityElement = true
            segmentCell.accessibilityLabel = data.title

            if let accessibilitIdentifier = data.accessibilityIdentifier {
                segmentCell.accessibilityIdentifier = accessibilitIdentifier
            }

            return segmentCell
        }

        // MARK: UICollectionViewDelegate

        fileprivate func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            segmentedControl.selectedSegmentIndex = indexPath.item
        }

        fileprivate func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            segmentedControl.delegate?.fetchImage(at: indexPath.item, completion: { (image, url) in
                if let imageSegmentCell = cell as? BaseImageSegmentCollectionViewCell, imageSegmentCell.imageUrl == url {
                    DispatchQueue.main.async {
                        imageSegmentCell.imageView.image = image
                    }
                }
            })

            var label:UILabel?
            if let _cell = cell as? TextOnlySegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnTopSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnLeftSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else {
                label = nil
            }

            if let titleLabel = label {
                let data = segmentedControl.segmentsData[indexPath.item]

                if cell.isHighlighted && data.highlightedAttributedTitle != nil {
                    titleLabel.attributedText = data.highlightedAttributedTitle!
                } else if cell.isSelected && data.selectedAttributedTitle != nil {
                    titleLabel.attributedText = data.selectedAttributedTitle!
                } else {
                    if data.normalAttributedTitle != nil {
                        titleLabel.attributedText = data.normalAttributedTitle!
                    }
                }
            }
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let data = segmentedControl.segmentsData[indexPath.item]
            if segmentedControl.hasDynamicSegmentSize, let title = data.title {
                return CGSize(width: segmentedControl.calculateTextWidth(title), height: segmentedControl.frame.size.height )
            }
            return segmentedControl.flowLayout.itemSize
        }
    }

    // MARK: - SegmentCollectionViewCell

    private class BaseSegmentCollectionViewCell: UICollectionViewCell {
        static let textPadding:CGFloat = 8.0
        static let imageToTextMargin:CGFloat = 14.0
        static let imageSize:CGFloat = 14.0
        static let defaultFont = UIFont.systemFont(ofSize: 14)
        static let defaultTextColor = UIColor.darkGray

        var underlineView:UIView?
        public var contentColor:UIColor?
        public var selectedContentColor:UIColor?

        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?

        var showUnderline:Bool = false {
            didSet {
                if oldValue != showUnderline {
                    if oldValue == false && underlineView != nil {
                        underlineView?.removeFromSuperview()
                    } else {
                        underlineView = UIView()
                        underlineView!.tag = 999
                        underlineView!.backgroundColor = tintColor
                        underlineView!.isHidden = !isSelected
                        underlineView!.layer.cornerRadius = 2.0
                        underlineView!.layer.masksToBounds = true
                        underlineView!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                        contentView.insertSubview(underlineView!, at: contentView.subviews.count)
                    }

                    configureConstraints()
                }
            }
        }

        override var tintColor: UIColor!{
            didSet{
                underlineView?.backgroundColor = tintColor
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            configure()
        }

        func configure() {
            configureConstraints()
        }

        private func configureConstraints() {
            if let underline = underlineView {
                underline.translatesAutoresizingMaskIntoConstraints = false
                underline.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
                underline.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: GlassSpacing.xxSmall
                ).isActive = true
                underline.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -GlassSpacing.xxSmall
                ).isActive = true
                underline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            }
        }

        override var isHighlighted: Bool {
            didSet {
                underlineView?.isHidden = !isHighlighted
                self.layer.borderWidth = isHighlighted ? 2.0: 0.0
                self.layer.borderColor = isHighlighted
                    ? GlassColor.blue100.uiColor.cgColor: GlassColor.gray00.uiColor.cgColor
            }
        }

        override var isSelected: Bool {
            didSet {
                if isSelected {
                    accessibilityTraits = UIAccessibilityTraits(rawValue: UIAccessibilityTraits.button.rawValue + UIAccessibilityTraits.selected.rawValue)
                } else {
                    accessibilityTraits = UIAccessibilityTraits.button
                }
                underlineView?.isHidden = !isSelected
            }
        }
    }

    private class TextOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()

        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }

        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }

        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
            }
        }

        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                }
            }
        }

        override func configure(){
            super.configure()
            contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = BaseSegmentCollectionViewCell.defaultTextColor
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
    }

    private class ImageOnlySegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {

        override var contentColor:UIColor? {
            didSet {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }

        override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override var isSelected: Bool {
            didSet {
                if isSelected {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override func configure(){
            super.configure()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = BaseSegmentCollectionViewCell.defaultTextColor

            contentView.addSubview(imageView)
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            imageView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }

    private class ImageOnTopSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
        let titleLabel = UILabel()
        static let cellPadding:CGFloat = 4.0

        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }

        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }

        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }

                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override func configure(){
            super.configure()
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(titleLabel)
            contentView.addSubview(imageView)
            titleLabel.heightAnchor.constraint(equalToConstant: GlassSpacing.medium).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ImageOnTopSegmentCollectionViewCell.cellPadding).isActive = true
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -ImageOnTopSegmentCollectionViewCell.cellPadding).isActive = true
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ImageOnTopSegmentCollectionViewCell.cellPadding).isActive = true
        }
    }

    private class ImageOnLeftSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
        let titleLabel = UILabel()

        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }

        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }

        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }

                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }

        override func configure(){
            super.configure()
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            contentView.addSubview(titleLabel)
            contentView.addSubview(imageView)

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false

            imageView.heightAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }

    private class BaseImageSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let imageView = UIImageView()
        var imageUrl: URL?
        var placeholderImage: UIImage? {
            didSet {
                guard placeholderImage != nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = self.placeholderImage
                }
            }
        }

    }
}
// swiftlint:enable line_length
