//
//  Bundle+GlassUI.swift
//  GlassUI
//
//  Created by Cihan Cimen on 7/9/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import Foundation

private class BundleFinder {}

extension Bundle {

    static var glassUIBundle: Bundle {
        // This is a port of the generated `Bundle.module` when using SPM:
        // https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package
        // Look for a Swift Package Manager bundle.
        let bundleName = "glass-platform_GlassUI"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        // No SPM bundle found, return legacy GlassUI bundle
        return moduleBundle(for: GlassComponentManager.self)
    }

    /// The Walmart App bundle
    public class var mainApp: Bundle {
        let main = Bundle.main

        // we only need to do extra work if this is a plugin
        guard main.isPlugin else { return main }

        // all Plugins live inside a subfolder of the main app's container, so find the "root" (main app)
        // by cutting off components that aren't Demo.app
        let components = main.resourceURL!.pathComponents
        let mainAppPathIndex = components.firstIndex(where: { $0 == "Walmart.app" })!

        return Bundle(path: components[...mainAppPathIndex].joined(separator: "/"))!
    }

    /// The GlassUI demo app bundle
    class var demoApp: Bundle {
        let main = Bundle.main

        // we only need to do extra work if this is a plugin
        guard main.isPlugin else { return main }

        // all Plugins live inside a subfolder of the main app's container, so find the "root" (main app)
        // by cutting off components that aren't Demo.app
        let components = main.resourceURL!.pathComponents
        let mainAppPathIndex = components.firstIndex(where: { $0 == "Demo.app" })!

        return Bundle(path: components[...mainAppPathIndex].joined(separator: "/"))!
    }

    /// returns `true` if main bundle is an extension bundle
    public var isPlugin: Bool {
        return Bundle.main.resourcePath?.contains("PlugIns") ?? false
    }

    /// Returns bundle of a class type that belongs to a static framework.
    ///
    /// Returned value is implicitly unwrapped to mirror Bundle.init(for: AnyClass).
    /// Make sure bundle exists when using this method.
    ///
    /// This method looks for a bundle in following directory under main bundle's resource path:
    /// "{Module}Resources.bundle"
    ///
    /// In unit test targets, this method looks for the same bundle under given class's bundle resource path.
    ///
    /// - Parameter klass: Any class type that belongs to a static framework.
    /// - Returns: Bundle instance that contains static framework resources.
    public static func moduleBundle(for klass: AnyClass) -> Bundle! {
        let resourcePath = Bundle.mainApp.resourcePath
        guard let actualResourcePath = resourcePath,
            let moduleName = String(reflecting: klass).split(separator: ".").first
            else {
                assertionFailure("Module name not found for class: \(klass.debugDescription())")
                return nil
        }
        let bundleName = "\(moduleName)Resources.bundle"
        let bundlePath = "\(actualResourcePath)/\(bundleName)"
        guard let bundle = Bundle(path: bundlePath) ?? searchBundles(for: bundleName) else {
//            if let isUnitTesting = ProcessInfo.processInfo.environment["isUnitTesting"],
//                isUnitTesting == "YES" {
//                return Bundle.main
//            } else {
//                assertionFailure("Bundle not found at path: \(bundlePath)")
//                return nil
//            }
            return Bundle.main
        }
        return bundle
    }

    /// searches all the bundles and checks if they house the provided bundle (e.g. unit tests)
    private static func searchBundles(for bundleName: String) -> Bundle? {
        (Bundle.allBundles + CollectionOfOne(Bundle(for: GlassComponentManager.self)))
            .compactMap { $0.resourcePath }
            .first(where: { (try? FileManager.default.contentsOfDirectory(atPath: $0).contains(bundleName)) ?? false })
            .flatMap({ Bundle(path: "\($0)/\(bundleName)" ) })
    }
}
