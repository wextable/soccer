////
////  DemoView.swift
////  GlassUI
////
////  Created by Eric Reedy on 4/1/21.
////  Copyright © 2021 Walmart. All rights reserved.
////
//
//import UIKit
//import WalmartPlatform
//
///// Provides an instance of `UIWindow` with a handy convenience initializer intended for use in Demo Apps.
///// Upon initialization, `layer.speed` is increased by 1000x if UI Tests are determined to be running.
/////
//public final class DemoWindow: UIWindow {
//
//    public convenience init() {
//        self.init(frame: UIScreen.main.bounds)
//    }
//
//    /// Initializes, assigns the provided view controller to `UIWindow.rootViewController`,
//    /// and then calls `makeKeyAndVisible()`.  If UI Tests are currently running, animation
//    /// speeds will also be increased by 1000x.
//    ///
//    public convenience init(with rootViewController: UIViewController) {
//        self.init(frame: UIScreen.main.bounds)
//        self.rootViewController = rootViewController
//        makeKeyAndVisible()
//    }
//
//    /// Initializes with the provided window scene, assigns the provided view controller
//    /// to `UIWindow.rootViewController`, and then calls `makeKeyAndVisible()`.
//    /// If UI Tests are currently running, animation speeds will also be increased by 1000x.
//    ///
//    public convenience init(with windowScene: UIWindowScene,
//                            and rootViewController: UIViewController)
//    {
//        self.init(windowScene: windowScene)
//        self.rootViewController = rootViewController
//        makeKeyAndVisible()
//    }
//
//    /// Initializes with the given frame.  Additionally, if UI Tests are currently running, animation
//    /// speeds will also be increased by 1000x.
//    ///
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        if UIApplication.uiTestsAreRunning {
//            layer.speed = 1000
//        }
//    }
//
//    /// Initializes with the given windowScene.  Additionally, if UI Tests are currently running, animation
//    /// speeds will also be increased by 100x.
//    ///
//    override public init(windowScene: UIWindowScene) {
//        super.init(windowScene: windowScene)
//
//        if UIApplication.uiTestsAreRunning {
//            layer.speed = 1000
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) not implemented.")
//    }
//}
