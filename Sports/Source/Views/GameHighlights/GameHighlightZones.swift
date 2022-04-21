//
//  GameHighlightZones.swift
//  Sports
//
//  Created by Wesley St. John on 3/3/22.
//

import UIKit

struct GameHighlightZones {

    private let screen = UIScreen.main.bounds

    private let imageWidth: CGFloat = 548.0
    private let imageHeight: CGFloat = 854.0

    private let fieldImageWidth: CGFloat = 528.0
    private let fieldImageXOffset: CGFloat = 10.0
    private let fieldImageYOffset: CGFloat = 40.0

    private let goalImageWidth: CGFloat = 116.0
    private let goalImageHeight: CGFloat = 34.0
    private let goalImageYOffset: CGFloat = 6.0

    private let penaltySpotImageYOffset: CGFloat = 154.0

    private var screenToImageScaleFactor: CGFloat {
        return screen.size.width / imageWidth
    }

    var attackerSpeedFactor: CGFloat {
        return 0.6 * screenToImageScaleFactor
    }

    var defenderSpeedFactor: CGFloat {
        return 0.4 * screenToImageScaleFactor
    }

    var keeperDivingSpeedFactor: CGFloat {
        return 1.0 * screenToImageScaleFactor
    }

    var passSpeedFactor: CGFloat {
        return 6.0 * screenToImageScaleFactor
    }

    var shotSpeedFactor: CGFloat {
        return 8.0 * screenToImageScaleFactor
    }

    var field: CGRect {
        let yOffset = fieldImageYOffset * screenToImageScaleFactor
        return CGRect(x: fieldImageXOffset * screenToImageScaleFactor,
                      y: yOffset,
                      width: fieldImageWidth * screenToImageScaleFactor,
                      height: screen.size.height - yOffset)
    }

    var goal: CGRect {
        let width = goalImageWidth * screenToImageScaleFactor
        return CGRect(x: screen.size.width / 2.0 - width / 2.0,
                      y: goalImageYOffset * screenToImageScaleFactor,
                      width: width,
                      height: goalImageHeight * screenToImageScaleFactor)
    }

    var centerBackOfGoal: CGPoint {
        return CGPoint(x: goal.origin.x + goal.size.width / 2.0,
                       y: goal.origin.y)
    }

    var penaltySpot: CGPoint {
        return CGPoint(x: screen.size.width / 2.0,
                       y: penaltySpotImageYOffset * screenToImageScaleFactor)
    }

    var playerSize: CGSize {
        let playerWidthPercentOfGoalWidth = 0.2
        let width = playerWidthPercentOfGoalWidth * goal.size.width
        return CGSize(width: width,
                      height: width / 2.0)
    }

    var ballSize: CGFloat {
        return playerSize.width * 0.4
    }

    var keeper: CGRect {
        let width = goalImageWidth * screenToImageScaleFactor
        return CGRect(x: screen.size.width / 2.0 - width / 2.0,
                      y: fieldImageYOffset * screenToImageScaleFactor,
                      width: width,
                      height: 12.0 * screenToImageScaleFactor)
    }

    var oneAttackerStart: CGRect {
        let zoneWidthOfField: CGFloat = 0.5
        let zoneHeightOfField: CGFloat = 0.33
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return CGRect(x: field.origin.x + field.size.width / 2.0 - width * 0.5,
                      y: screen.size.height - height,
                      width: width,
                      height: height)
    }

    var twoAttackerStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.33
        let zoneHeightOfField: CGFloat = 0.33
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0,
                       y: screen.size.height - height,
                       width: width,
                       height: height)
        ]
    }

    var threeAttackerStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.25
        let zoneHeightOfField: CGFloat = 0.33
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width * 1.5,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 - width * 0.5,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 + width * 0.5,
                       y: screen.size.height - height,
                       width: width,
                       height: height)
        ]
    }

    var fourAttackerStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.2
        let zoneHeightOfField: CGFloat = 0.33
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width * 2.0,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 - width,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0,
                       y: screen.size.height - height,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 + width,
                       y: screen.size.height - height,
                       width: width,
                       height: height)
        ]
    }

    private var attackerMovement: CGRect {
        let minXMovementOfFieldWidth: CGFloat = -0.1
        let maxXMovementOfFieldWidth: CGFloat = 0.1
        let minYMovementOfFieldHeight: CGFloat = -0.33
        let maxYMovementOfFieldHeight: CGFloat = -0.1

        let minX = minXMovementOfFieldWidth * field.size.width
        let maxX = maxXMovementOfFieldWidth * field.size.width
        let minY = minYMovementOfFieldHeight * field.size.height
        let maxY = maxYMovementOfFieldHeight * field.size.height

        return CGRect(x: minX,
                      y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }

    private var otherAttackerMovement: CGRect {
        let minXMovementOfFieldWidth: CGFloat = -0.15
        let maxXMovementOfFieldWidth: CGFloat = 0.15
        let minYMovementOfFieldHeight: CGFloat = -0.5
        let maxYMovementOfFieldHeight: CGFloat = -0.2

        let minX = minXMovementOfFieldWidth * field.size.width
        let maxX = maxXMovementOfFieldWidth * field.size.width
        let minY = minYMovementOfFieldHeight * field.size.height
        let maxY = maxYMovementOfFieldHeight * field.size.height

        return CGRect(x: minX,
                      y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }

    private var attackerMovementAfterPass: CGRect {
        let minXMovementOfFieldWidth: CGFloat = -0.025
        let maxXMovementOfFieldWidth: CGFloat = 0.025
        let minYMovementOfFieldHeight: CGFloat = -0.15
        let maxYMovementOfFieldHeight: CGFloat = 0

        let minX = minXMovementOfFieldWidth * field.size.width
        let maxX = maxXMovementOfFieldWidth * field.size.width
        let minY = minYMovementOfFieldHeight * field.size.height
        let maxY = maxYMovementOfFieldHeight * field.size.height

        return CGRect(x: minX,
                      y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }

    var oneDefenderStart: CGRect {
        let zoneWidthOfField: CGFloat = 0.5
        let zoneHeightOfField: CGFloat = 0.67
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return CGRect(x: field.origin.x + field.size.width / 2.0 - width * 0.5,
                      y: field.origin.y,
                      width: width,
                      height: height)
    }

    var twoDefenderStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.33
        let zoneHeightOfField: CGFloat = 0.67
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0,
                       y: field.origin.y,
                       width: width,
                       height: height)
        ]
    }

    var threeDefenderStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.25
        let zoneHeightOfField: CGFloat = 0.67
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width * 1.5,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 - width * 0.5,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 + width * 0.5,
                       y: field.origin.y,
                       width: width,
                       height: height)
        ]
    }

    var fourDefenderStart: [CGRect] {
        let zoneWidthOfField: CGFloat = 0.2
        let zoneHeightOfField: CGFloat = 0.67
        let width = field.size.width * zoneWidthOfField
        let height = field.size.height * zoneHeightOfField
        return [CGRect(x: field.origin.x + field.size.width / 2.0 - width * 2.0,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 - width,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0,
                       y: field.origin.y,
                       width: width,
                       height: height),
                CGRect(x: field.origin.x + field.size.width / 2.0 + width,
                       y: field.origin.y,
                       width: width,
                       height: height)
        ]
    }
}

extension GameHighlightZones {

    func randomKeeperStart() -> CGPoint {
        return keeper.randomPoint
    }

    func penaltyKeeperStart() -> CGPoint {
        return CGPoint(x: keeper.origin.x + keeper.size.width / 2.0,
                       y: keeper.origin.y + 6.0 * screenToImageScaleFactor)
    }

    func randomAttackerStarts(numAttackers: Int) -> [CGPoint] {
        var zones: [CGRect]
        switch numAttackers {
        case 1: zones = [oneAttackerStart]
        case 2: zones = twoAttackerStart
        case 3: zones = threeAttackerStart
        case 4: zones = fourAttackerStart
        default: return []
        }

        let points = zones.map { $0.randomPoint }
        return points.shuffled()
    }

    func penaltyAttackerStart() -> CGPoint {
        return CGPoint(x: penaltySpot.x,
                       y: penaltySpot.y + 50.0)
    }

    func randomDefenderPositions(numDefenders: Int) -> [CGPoint] {
        var zones: [CGRect]
        switch numDefenders {
        case 1: zones = [oneDefenderStart]
        case 2: zones = twoDefenderStart
        case 3: zones = threeDefenderStart
        case 4: zones = fourDefenderStart
        default: return []
        }

        return zones.map { $0.randomPoint }
    }

    func randomAttackerMovement() -> CGPoint {
        return attackerMovement.randomPoint
    }

    func randomOtherAttackerMovement() -> CGPoint {
        return otherAttackerMovement.randomPoint
    }

    func randomAttackerMovementAfterPass() -> CGPoint {
        return attackerMovementAfterPass.randomPoint
    }

    func randomBackOfGoal(fromShotOrigin shotOrigin: CGPoint) -> CGPoint {
        let leftGoalPost = goal.origin.x
        let rightGoalPost = goal.origin.x + goal.size.width
        var minX = leftGoalPost
        var maxX = rightGoalPost
        let rise = (goal.origin.y + goal.size.height) - shotOrigin.y

        if shotOrigin.x < leftGoalPost {
            let run = leftGoalPost - shotOrigin.x
            let slope = rise / run
            let xInset = goal.size.height / slope
            minX = min(leftGoalPost - xInset, goal.origin.x + goal.size.width)
        } else if shotOrigin.x > rightGoalPost {
            let run = rightGoalPost - shotOrigin.x
            let slope = rise / run
            let xInset = goal.size.height / slope
            maxX = max(rightGoalPost - xInset, leftGoalPost)
        }

        return CGPoint(x: CGFloat.random(in: minX...maxX),
                       y: goal.origin.y)

    }

    func randomMissBallPosition(fromShotOrigin shotOrigin: CGPoint) -> CGPoint {
        if Int.random(in: 0..<100) < 50 {
            return randomMissBallPositionLeft(fromShotOrigin: shotOrigin)
        } else {
            return randomMissBallPositionRight(fromShotOrigin: shotOrigin)
        }
    }

    func randomMissBallPositionLeft(fromShotOrigin shotOrigin: CGPoint) -> CGPoint {
        let y: CGFloat = -40
        let leftGoalPost = goal.origin.x
        var maxX = screen.size.width

        var goalHeightAdjustment: CGFloat = 0
        if shotOrigin.x > leftGoalPost {
            goalHeightAdjustment = goal.size.height
        }
        let rise = (goal.origin.y + goalHeightAdjustment) - shotOrigin.y
        let run = leftGoalPost - shotOrigin.x
        let slope = rise / run
        let xInset = (goal.origin.y + goalHeightAdjustment - y) / slope
        maxX = max(leftGoalPost - xInset, 0)

        return CGPoint(x: CGFloat.random(in: 0...maxX),
                       y: y)
    }

    func randomMissBallPositionRight(fromShotOrigin shotOrigin: CGPoint) -> CGPoint {
        let y: CGFloat = -40
        let rightGoalPost = goal.origin.x + goal.size.width
        var minX: CGFloat = 0

        var goalHeightAdjustment: CGFloat = 0
        if shotOrigin.x < rightGoalPost {
            goalHeightAdjustment = goal.size.height
        }
        let rise = (goal.origin.y + goalHeightAdjustment) - shotOrigin.y
        let run = rightGoalPost - shotOrigin.x
        let slope = rise / run
        let xInset = (goal.origin.y + goalHeightAdjustment - y) / slope
        minX = min(rightGoalPost - xInset, screen.size.width)

        return CGPoint(x: CGFloat.random(in: minX...screen.size.width),
                       y: y)
    }

    func randomSavePosition() -> CGPoint {
        let goalLineY = goal.origin.y + goal.size.height + 10.0
        return CGPoint(x: goal.randomPoint.x,
                       y: CGFloat.random(in: goalLineY...(goalLineY + 30.0)))

    }
}

private extension CGRect {
    var randomPoint: CGPoint {
        return CGPoint(x: CGFloat.random(in: origin.x...origin.x+size.width),
                       y: CGFloat.random(in: origin.y...origin.y+size.height))
    }
}

extension CGPoint {
    var magnitude: CGFloat {
        return (x*x + y*y).squareRoot()
    }
}
