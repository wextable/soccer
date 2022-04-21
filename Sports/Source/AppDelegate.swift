//
//  AppDelegate.swift
//  Sports
//
//  Created by Wesley St. John on 12/21/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var homeCoordinator: HomeCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupUIAppearance()

        window = UIWindow()
        homeCoordinator = HomeCoordinator(window: self.window!)
        homeCoordinator?.start()
        
        return true
    }

}

extension AppDelegate {

    func setupUIAppearance() {

        // UINavigationBar
        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
//        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().backgroundColor = .white
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]

        // UISegmentedControl
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .normal)
        UISegmentedControl.appearance().selectedSegmentTintColor = .white

        // UITableView
        UITableView.appearance().showsHorizontalScrollIndicator = false
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
}
