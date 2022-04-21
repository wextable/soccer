////  Copyright © 2020 Walmart. All rights reserved.
//
//import UIKit
//import WalmartPlatform
//
///// Type of the component
//public enum ComponentType {
//    /// Button
//    case button
//}
//
///// Delegate corresponding to feature update view
//public protocol GlassFeatureUpdateViewDelegate: AnyObject {
//    /// Delegate method to know when user taps on `Feature Update View` to perform update action
//    /// - Parameters:
//    ///   - name: Name of the component (ie, button name)
//    ///   - componentType: Type of the component
//    func didTriggerUpdate(_ name: String, componentType: ComponentType)
//}
//
///// Handles feature level nudge updates
/////
///// Add this component to your view hierarcy so that folks know about your amazing new features.
///// You'll want to gate it's visibility on a CCM Versioned Value with a maximum version,
///// so it shows for folks who've not yet updated.
/////
///// https://app.zeplin.io/project/5e8beacd00f01f232e80126d/screen/5f8dcc8a7c94fc369ead9df9
/////
//public class GlassFeatureUpdateView: GlassUI.BaseView, GlassAlertMessageDelegate {
//
//    private let messageView: GlassAlertMessage
//
//    private var appStoreURLOpening: ApplicationURLHandler = UIApplication.shared
//    private let appStoreURL: URL
//    private static let updateTitle = "nudge-update.cta.title".localize()
//
//    /// GlassFeatureUpdateViewDelegate
//    public weak var updateViewDelegate: GlassFeatureUpdateViewDelegate?
//    /// Preferred init
//    ///
//    /// Pass in a message like 'Walmart+ is here!" and a default "Please update..."
//    /// message will be attribued and applied for you.
//    ///
//    public convenience init(featureMessage: String, appStoreURL: URL) {
//        let updateMessage = "nudge-update.message".localize()
//        let content = "\(featureMessage) \(Self.updateTitle) \(updateMessage)"
//        let underlineRange = (content as NSString).range(of: Self.updateTitle)
//        let featureMessageFull = NSMutableAttributedString(string: content)
//        featureMessageFull.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: underlineRange)
//
//        self.init(message: featureMessageFull, appStoreURL: appStoreURL)
//    }
//
//    /// Convenient init method so you can "just" pass a custom`message: String`
//    public convenience init(message: String, appStoreURL: URL) {
//        let attributedMessage = NSAttributedString(string: message)
//        self.init(message: attributedMessage, appStoreURL: appStoreURL)
//    }
//
//    /// Pass any attributes string message
//    ///
//    /// You control all the content and the attributes.
//    public init(message: NSAttributedString, appStoreURL: URL) {
//
//        let model = GlassAlertMessage.GlassAlertMessageModel(message: message,
//                                                             messageType: .information,
//                                                             image: GlassIcon.infoCircle,
//                                                             isTappable: true)
//
//        messageView = GlassAlertMessage(model: model)
//        self.appStoreURL = appStoreURL
//        super.init(frame: .zero)
//    }
//
//    public override func constructView() {
//        super.constructView()
//        messageView.delegate = self
//    }
//
//    public override func constructSubviewHierarchy() {
//        super.constructSubviewHierarchy()
//        addAutoLayoutSubview(messageView)
//    }
//
//    public override func constructSubviewLayoutConstraints() {
//        super.constructSubviewLayoutConstraints()
//        NSLayoutConstraint.activate([
//            messageView.constraints(pinningTo: self)
//        ])
//    }
//
//    public func didSelectRightButton(sender: GlassAlertMessage) {
//        // no op - This view is not configured with a right button.
//    }
//
//    public func didTapAlert(sender: GlassAlertMessage) {
//        updateViewDelegate?.didTriggerUpdate(Self.updateTitle, componentType: .button)
//        appStoreURLOpening.open(appStoreURL)
//    }
//}
//
//private extension ApplicationURLHandler {
//    func open(_ url: URL) {
//        open(url, options: [:], completionHandler: nil)
//    }
//}
//
//#if DEBUG
//extension GlassFeatureUpdateView {
//    var testHooks: TestHooks {
//        .init(target: self)
//    }
//
//    struct TestHooks {
//        let target: GlassFeatureUpdateView
//
//        // can't use initializer injection since `AppStoreURLOpening` is an internal type.
//        func setAppStoreOpener(_ mock: ApplicationURLHandler) {
//            target.appStoreURLOpening = mock
//        }
//
//        var messageView: GlassAlertMessage {
//            target.messageView
//        }
//    }
//}
//#endif
