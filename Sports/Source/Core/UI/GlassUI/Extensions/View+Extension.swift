//
//  View+Extension.swift
//  GlassUI
//
//  Created by Amisha Chordia on 21/07/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

public extension View {
    func onReceive(_ name: Notification.Name,
                   center: NotificationCenter = .default,
                   object: AnyObject? = nil,
                   perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(
            center.publisher(for: name, object: object), perform: action
        )
    }

    func format(toSentenceCase title: String, shouldFormat: Bool) -> String {
        shouldFormat ? title.toSentenceCase() : title
    }
}
