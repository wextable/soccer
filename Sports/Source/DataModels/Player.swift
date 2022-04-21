//
//  Player.swift
//  Sports
//
//  Created by Wesley St. John on 12/21/21.
//

import Foundation
import UIKit

class Player: NSObject, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let height: Double
    let weight: Int
    let position: Position

    var age: Int
    var condition: Int
    var morale: Morale
    var contract: Contract?
    var teamId: String?
    var jerseyNumber: Int
    var isCaptain: Bool

    var ratings: Ratings
    var potential: Ratings
    var xp: Int
    var xpLevel: Int
    var potentialXP: Int {
        return xpLevel * 10 + 100
    }

    // https://www.goal.com/en-us/news/fifa-player-ratings-explained-how-are-the-card-number-stats/1hszd2fgr7wgf1n2b2yjdpgynu
    var stats: Stats = .init()

    init(id: String,
         firstName: String,
         lastName: String,
         height: Double,
         weight: Int,
         position: Position,
         age: Int,
         condition: Int,
         morale: Morale,
         contract: Contract?,
         teamId: String?,
         jerseyNumber: Int,
         isCaptain: Bool,
         ratings: Ratings,
         potential: Ratings,
         xp: Int,
         xpLevel: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.height = height
        self.weight = weight
        self.position = position
        self.age = age
        self.condition = condition
        self.morale = morale
        self.contract = contract
        self.teamId = teamId
        self.jerseyNumber = jerseyNumber
        self.isCaptain = isCaptain
        self.ratings = ratings
        self.potential = potential
        self.xp = xp
        self.xpLevel = xpLevel
    }
}

extension Player {
    enum Morale: String, CaseIterable, Equatable, Codable {
        case angry
        case sad
        case ok
        case happy
        case thrilled
    }

    struct Contract: Equatable, Codable {
        var duration: Int
        var salary: Int
    }

    enum Rating {
        case speed
        case shooting
        case passing
        case dribbling
        case defending
        case goalkeeping

        var name: String {
            switch self {
            case .speed: return "Speed"
            case .shooting: return "Shooting"
            case .passing: return "Passing"
            case .dribbling: return "Dribbling"
            case .defending: return "Defending"
            case .goalkeeping: return "Goalkeeping"
            }
        }
    }

    struct Ratings: Equatable, Codable {
        var position: Position = .keeper
        var speed: Int = 0
        var shooting: Int = 0
        var passing: Int = 0
        var dribbling: Int = 0
        var defending: Int = 0
        var goalkeeping: Int = 0

        var overall: Int {
            var overall: Double
            switch position {
            case .keeper:
                overall = Double(speed) * 0.01 +
                Double(shooting) * 0.01 +
                Double(passing) * 0.1 +
                Double(dribbling) * 0.02 +
                Double(defending) * 0.25 +
                Double(goalkeeping) * 0.61
            case .defender:
                overall = Double(speed) * 0.18 +
                Double(shooting) * 0.02 +
                Double(passing) * 0.15 +
                Double(dribbling) * 0.05 +
                Double(defending) * 0.6
            case .midfielder:
                overall = Double(speed) * 0.22 +
                Double(shooting) * 0.18 +
                Double(passing) * 0.26 +
                Double(dribbling) * 0.2 +
                Double(defending) * 0.14
            case .forward:
                overall = Double(speed) * 0.3 +
                Double(shooting) * 0.3 +
                Double(passing) * 0.1 +
                Double(dribbling) * 0.28 +
                Double(defending) * 0.02
            }

            return Int(overall)
        }

        var overallScoring: Int {
            return Int(Double(shooting) * 0.4 +
                       Double(speed) * 0.3 +
                       Double(dribbling) * 0.25 +
                       Double(passing) * 0.05)
        }

        var overallDefensive: Int {
            return Int(Double(defending) * 0.6 +
                       Double(speed) * 0.25 +
                       Double(dribbling) * 0.05 +
                       Double(passing) * 0.1)
        }

        var overallAssist: Int {
            return Int(Double(speed) * 0.4 +
                       Double(dribbling) * 0.25 +
                       Double(passing) * 0.35)
        }

        var offensiveStarRating: Double {
            return overallStarRating(overall: overallScoring)
        }

        var defensiveStarRating: Double {
            switch position {
            case .keeper: return overallStarRating(overall: overall)
            default: return overallStarRating(overall: overallDefensive)
            }
        }

        var overallStarRating: Double {
            return overallStarRating(overall: overall)
        }

        private func overallStarRating(overall: Int) -> Double {
            switch overall {
            case Int.min..<64: return 0.5
            case 64..<67: return 1.0
            case 67..<70: return 1.5
            case 70..<73: return 2.0
            case 73..<76: return 2.5
            case 76..<79: return 3.0
            case 79..<82: return 3.5
            case 82..<85: return 4.0
            case 85..<88: return 4.5
            default: return 5.0
            }
        }
    }
}

extension Player {

    struct Stats: Equatable, Codable {
        var goals: Int = 0
        var assists: Int = 0
        var saves: Int = 0
        var cleanSheets: Int = 0
    }
}

extension Player {
    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var firstInitialAndLastName: String {
        return "\(firstName.prefix(1)). \(lastName)"
    }

    func increaseXp(by amount: Int) {
        xp = min(xp + amount, potentialXP)
    }
}

extension Player {
    var desc: String {
        var description = "\(firstName) \(lastName) (\(position))\n"
//        description += "Age: \(age), Height: \(feetToFeetInches(height)), Weight: \(weight) lbs\n"
//        description += "Condition: \(condition)%, Morale: \(morale)\n"
        description += "OVERALL: \(ratings.overall)\n"
        description += "Speed: \(ratings.speed)\n"
        description += "Shooting: \(ratings.shooting)\n"
        description += "Passing: \(ratings.passing)\n"
        description += "Dribbling: \(ratings.dribbling)\n"
//        description += "Defending: \(ratings.defending)\n"
//        description += "Goalkeeping: \(ratings.goalkeeping)"
        return description
    }

}

func feetToFeetInches(_ value: Double) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .short

    let rounded = value.rounded(.towardZero)
    let feet = Measurement(value: rounded, unit: UnitLength.feet)
    let inches = Measurement(value: ((value - rounded)*12.0).rounded(.towardZero), unit: UnitLength.inches)
    return ("\(formatter.string(from: feet))\(formatter.string(from: inches))")
}
