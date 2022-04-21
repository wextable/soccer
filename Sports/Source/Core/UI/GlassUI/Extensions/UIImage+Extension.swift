//
//  UIImageExtensions.swift
//  GlassUI
//
//  Created by Tres Spicher on 3/21/18.
//  Copyright © 2018 Walmart. All rights reserved.
//

import UIKit

public extension UIImage {
    func resizedTo(targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        var newImage: UIImage?
        let renderer = UIGraphicsImageRenderer(size: newSize)
        newImage = renderer.image { _ in
            self.draw(in: rect)
        }

        if let newImage = newImage {
            return newImage
        }
        return self
    }

    func imageWithColor(color: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        color.setFill()
        draw(in: rect)
        context?.setBlendMode(.sourceIn)
        context?.fill(rect)

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return resultImage
    }

}
