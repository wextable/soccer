//
//  GlassString.swift
//  GlassUI
//
//  Created by Rupani, Sohil (US - Seattle) on 2/14/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(self, bundle: Bundle.glassUIBundle, comment: "")
    }

    func localize(_ arguments: CVarArg...) -> String {
        return withVaList(arguments, { NSString(format: localize(),
                                                locale: NSLocale.current,
                                                arguments: $0) }) as String
    }
}
