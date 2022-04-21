//
//  Image+Extension.swift
//  GlassUI
//
//  Created by Amisha Chordia on 01/06/21.
//  Copyright © 2021 Walmart. All rights reserved.
//

import SwiftUI

public extension Image {
    func resizedImage(size: CGSize, withRenderingMode mode: TemplateRenderingMode = .original) -> some View {
        self.resizable()
            .renderingMode(mode)
            .frame(width: size.width, height: size.height)
    }
}
