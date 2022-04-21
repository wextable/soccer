//
//  FaceFactory.swift
//  Sports
//
//  Created by Wesley St. John on 2/18/22.
//

import UIKit

class FaceFactory {

    static func makeFace(teamPrimaryColor: UIColor,
                         teamSecondaryColor: UIColor) -> UIImage {
        let layers = [getFaceBackground(teamPrimaryColor: teamPrimaryColor,
                                        teamSecondaryColor: teamSecondaryColor),
                      getEyes(),
                      getEyebrows(),
                      getMouth(),
                      getMustache(),
                      getNose(),
                      getBeard(),
                      getHair()]
        return compositeImages(images: layers.compactMap { $0 })
    }
}

extension FaceFactory {

    private static let numFaceBackgrounds = 1
    private static let numHairs = 2
    private static let numEyes = 2
    private static let numEyebrows = 2
    private static let numMouths = 2
    private static let numMustaches = 1
    private static let numNoses = 2
    private static let numBeards = 1

    private static func getFaceBackground(teamPrimaryColor: UIColor,
                                          teamSecondaryColor: UIColor) -> UIImage {
        let index = Int.random(in: 1...numFaceBackgrounds)

        var image = UIImage(named: "face_bg_\(index)") ?? UIImage()
        let skinColor = makeSkinColor()
        image = image.replacingColorAt(32, 22,
                                       withColor: skinColor,
                                       tolerance: 100,
                                       antialias: false)
        image = image.replacingColorAt(32, 47,
                                       withColor: skinColor,
                                       tolerance: 100,
                                       antialias: false)
        image = image.replacingColorAt(32, 55,
                                       withColor: teamSecondaryColor,
                                       tolerance: 100,
                                       antialias: false)
        return image.replacingColorAt(32, 61,
                                      withColor: teamPrimaryColor,
                                      tolerance: 100,
                                      antialias: false)
    }

    private static func getHair() -> UIImage? {
        guard Int.random(in: 0..<100) < 90 else { return nil }
        let index = Int.random(in: 1...numHairs)
        return UIImage(named: "face_hair_\(index)") ?? UIImage()
    }

    private static func getEyes() -> UIImage {
        let index = Int.random(in: 1...numEyes)
        return UIImage(named: "face_eyes_\(index)") ?? UIImage()
    }

    private static func getEyebrows() -> UIImage? {
        guard Int.random(in: 0..<100) < 95 else { return nil }
        let index = Int.random(in: 1...numEyebrows)
        return UIImage(named: "face_eyebrows_\(index)") ?? UIImage()
    }

    private static func getMouth() -> UIImage {
        let index = Int.random(in: 1...numMouths)
        return UIImage(named: "face_mouth_\(index)") ?? UIImage()
    }

    private static func getMustache() -> UIImage? {
        guard Int.random(in: 0..<100) < 10 else { return nil }
        let index = Int.random(in: 1...numMustaches)
        return UIImage(named: "face_mustache_\(index)") ?? UIImage()
    }

    private static func getNose() -> UIImage {
        let index = Int.random(in: 1...numNoses)
        return UIImage(named: "face_nose_\(index)") ?? UIImage()
    }

    private static func getBeard() -> UIImage? {
        guard Int.random(in: 0..<100) < 15 else { return nil }
        let index = Int.random(in: 1...numBeards)
        return UIImage(named: "face_beard_\(index)") ?? UIImage()
    }

    private static func compositeImages(images: [UIImage]) -> UIImage {
        var compositeImage: UIImage!
        if images.count > 0 {
            // Get the size of the first image.  This function assume all images are same size
            let size: CGSize = CGSize(width: images[0].size.width, height: images[0].size.height)
            UIGraphicsBeginImageContext(size)
            for image in images {
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                image.draw(in: rect)
            }
            compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return compositeImage
    }

    private static func makeSkinColor() -> UIColor {
        let colors: [UIColor] = [
            .rgb(r: 254, g: 227, b: 200),
            .rgb(r: 253, g: 230, b: 176),
            .rgb(r: 248, g: 216, b: 156),
            .rgb(r: 249, g: 211, b: 164),
            .rgb(r: 236, g: 192, b: 148),
            .rgb(r: 241, g: 194, b: 133),
            .rgb(r: 211, g: 158, b: 125),
            .rgb(r: 185, g: 101, b: 59),
            .rgb(r: 206, g: 150, b: 100),
            .rgb(r: 173, g: 138, b: 99),
            .rgb(r: 146, g: 95, b: 58),
            .rgb(r: 114, g: 63, b: 28),
            .rgb(r: 177, g: 102, b: 72),
            .rgb(r: 126, g: 69, b: 38),
            .rgb(r: 94, g: 51, b: 20),
            .rgb(r: 81, g: 43, b: 15)
        ]

        return colors.randomElement()!
    }
}
