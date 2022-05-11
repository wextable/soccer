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
    var morale: Morale
    var contract: Contract?
    var teamId: String?
    var jerseyNumber: Int
    var isCaptain: Bool

    var isStarting: Bool = false
    var condition: Int
    var injury: Injury?
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
         morale: Morale,
         contract: Contract?,
         teamId: String?,
         jerseyNumber: Int,
         isCaptain: Bool,
         condition: Int = 100,
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
        self.morale = morale
        self.contract = contract
        self.teamId = teamId
        self.jerseyNumber = jerseyNumber
        self.isCaptain = isCaptain
        self.condition = condition
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
        var speed: Int = 0
        var shooting: Int = 0
        var passing: Int = 0
        var dribbling: Int = 0
        var defending: Int = 0
        var goalkeeping: Int = 0

        func getOverall(for position: Position) -> Int {
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
                Double(defending) * 0.14 +
                2.0
            case .forward:
                overall = Double(speed) * 0.3 +
                Double(shooting) * 0.3 +
                Double(passing) * 0.1 +
                Double(dribbling) * 0.28 +
                Double(defending) * 0.02
            }

            return Int(overall)
        }

        func getOverallScoring() -> Int {
            return Int(Double(shooting) * 0.4 +
                       Double(speed) * 0.3 +
                       Double(dribbling) * 0.25 +
                       Double(passing) * 0.05)
        }

        func getOverallDefensive() -> Int {
            return Int(Double(defending) * 0.6 +
                       Double(speed) * 0.25 +
                       Double(dribbling) * 0.05 +
                       Double(passing) * 0.1)
        }

        func getOverallAssist() -> Int {
            return Int(Double(speed) * 0.4 +
                       Double(dribbling) * 0.25 +
                       Double(passing) * 0.35)
        }
    }

    var hasReachedPotential: Bool {
        return ratings.speed == potential.speed &&
        ratings.shooting == potential.shooting &&
        ratings.passing == potential.passing &&
        ratings.dribbling == potential.dribbling &&
        ratings.defending == potential.defending &&
        ratings.goalkeeping == potential.goalkeeping
    }
}

extension Player {

    var overallRating: Int {
        getOverallRating()
    }
    var overallRatingPotential: Int {
        getOverallRating(isPotential: true)
    }
    private func getOverallRating(isPotential: Bool = false) -> Int {
        guard !isPotential else { return potential.getOverall(for: position) }
        let overall = ratings.getOverall(for: position)
        return effectiveRating(overall)
    }

    var overallScoring: Int {
        getOverallScoring()
    }
    var overallScoringPotential: Int {
        getOverallScoring(isPotential: true)
    }
    private func getOverallScoring(isPotential: Bool = false) -> Int {
        guard !isPotential else { return potential.getOverallScoring() }
        let overall = ratings.getOverallScoring()
        return effectiveRating(overall)
    }

    var overallDefensive: Int {
        switch position {
        case .keeper: return getOverallRating()
        default: return getOverallDefensive()
        }
    }
    var overallDefensivePotential: Int {
        getOverallDefensive(isPotential: true)
    }
    private func getOverallDefensive(isPotential: Bool = false) -> Int {
        guard !isPotential else { return potential.getOverallDefensive() }
        let overall = ratings.getOverallDefensive()
        return effectiveRating(overall)
    }

    var overallAssist: Int {
        let assist = ratings.getOverallAssist()
        return effectiveRating(assist)
    }

    var offensiveStarRating: Double {
        getOffensiveStarRating()
    }
    var offensiveStarRatingPotential: Double {
        getOffensiveStarRating(isPotential: true)
    }
    private func getOffensiveStarRating(isPotential: Bool = false) -> Double {
        return getOverallStarRating(overall: getOverallScoring(isPotential: isPotential))
    }

    var defensiveStarRating: Double {
        getDefensiveStarRating()
    }
    var defensiveStarRatingPotential: Double {
        getDefensiveStarRating(isPotential: true)
    }
    private func getDefensiveStarRating(isPotential: Bool = false) -> Double {
        switch position {
        case .keeper: return getOverallStarRating(overall: getOverallRating(isPotential: isPotential))
        default: return getOverallStarRating(overall: getOverallDefensive(isPotential: isPotential))
        }
    }

    var overallStarRating: Double {
        getOverallStarRating()
    }
    var overallStarRatingPotential: Double {
        getOverallStarRating(isPotential: true)
    }
    private func getOverallStarRating(isPotential: Bool = false) -> Double {
        return getOverallStarRating(overall: getOverallRating(isPotential: isPotential))
    }

    private func getOverallStarRating(overall: Int) -> Double {
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

    private func effectiveRating(_ rating: Int) -> Int {
        let effectiveness: Double = 100 - ((100 - Double(condition)) * GameConfig.config.condition.effectivenesFactor)
        return Int(Double(rating) * (effectiveness/100))
    }
}

extension Player {

    struct Injury: Codable {
        let type: InjuryType
        private let causeDescription: String?

        private(set) var isNew: Bool = true
        private(set) var numWeeksToHeal: Int

        var isRecovered: Bool {
            numWeeksToHeal == 0
        }

        enum Severity: Int {
            case mild = 1
            case medium = 2
            case severe = 3
        }

        enum InjuryType: String, CaseIterable, Codable {
            case acl = "torn ACL"
            case aneurism = "aneurism"
            case ankle = "sprained ankle"
            case arm = "broken arm"
            case concussion = "concussion"
            case diarrhea = "wicked case of diarrhea"
            case ear = "cauliflower ear"
            case hamstring = "pulled hamstring"
            case hangover = "terrible fucking hangover"
            case jaw = "dislocated jaw"
            case neck = "broken neck"
            case nose = "broken nose"
            case rectum = "hemorraging rectum"
            case retina = "detached retina"
            case schlong = "badly bruised schlong"
            case testicle = "ruptured testicle"
            case toe = "severed toe"

            var duration: Int {
                switch self {
                case .acl: return Int.random(in: 6...10)
                case .aneurism: return Int.random(in: 6...10)
                case .ankle: return Int.random(in: 1...3)
                case .arm: return Int.random(in: 3...5)
                case .concussion: return Int.random(in: 1...2)
                case .diarrhea: return 1
                case .ear: return Int.random(in: 1...3)
                case .hamstring: return Int.random(in: 2...4)
                case .hangover: return 1
                case .jaw: return Int.random(in: 1...4)
                case .neck: return Int.random(in: 8...12)
                case .nose: return Int.random(in: 3...5)
                case .rectum: return Int.random(in: 3...5)
                case .retina: return Int.random(in: 2...3)
                case .schlong: return 1
                case .testicle: return Int.random(in: 4...8)
                case .toe: return Int.random(in: 2...3)
                }
            }

            var severity: Severity {
                switch self {
                case .acl: return .severe
                case .aneurism: return .severe
                case .ankle: return .mild
                case .arm: return .medium
                case .concussion: return .mild
                case .diarrhea: return .mild
                case .ear: return .mild
                case .hamstring: return .medium
                case .hangover: return .mild
                case .jaw: return .medium
                case .neck: return .severe
                case .nose: return .mild
                case .rectum: return .medium
                case .retina: return .medium
                case .schlong: return .mild
                case .testicle: return .severe
                case .toe: return .medium
                }
            }
        }

        static func makeRandom(maxSeverity: Severity, causeDescription: String? = nil) -> Self {
            let possibleTypes = InjuryType.allCases.filter { $0.severity.rawValue <= maxSeverity.rawValue }
            return self.init(type: possibleTypes.randomElement()!,
                             causeDescription: causeDescription)
        }

        private init(type: InjuryType, causeDescription: String? = nil) {
            self.type = type
            self.causeDescription = causeDescription
            self.numWeeksToHeal = type.duration
        }

        mutating func advanceWeek() {
            isNew = false
            numWeeksToHeal = max(0, numWeeksToHeal - 1)
        }

        func notification(playerName: String) -> String {
            var string = "\(playerName) has a \(type.rawValue)."
            if let cause = causeDescription {
                string += "\n\(cause)"
            }
            if numWeeksToHeal == 1 {
                string += "\nIt will take \(numWeeksToHeal) week to heal."
            } else {
                string += "\nIt will take \(numWeeksToHeal) weeks to heal."
            }
            return string
        }
    }

    var isInjured: Bool {
        return injury?.isRecovered == false
    }

    func addInjury(causeDescription: String = "") {
        let severity: Injury.Severity
        switch condition {
        case Int.min..<50: severity = .severe
        case 50..<80: severity = .medium
        default: severity = .mild
        }
        injury = .makeRandom(maxSeverity: severity, causeDescription: causeDescription)
        condition = 0
        isStarting = false
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
        if firstName.count == 0 {
            return lastName
        }
        return "\(firstName) \(lastName)"
    }

    var firstInitialAndLastName: String {
        if firstName.count == 0 {
            return lastName
        }
        return "\(firstName.prefix(1)). \(lastName)"
    }

    func increaseXp(by amount: Int) {
        xp = min(xp + amount, potentialXP)
    }

    func decreaseCondition(by amount: Int) {
        condition = max(0, condition - amount)
    }

    func increaseCondition(by amount: Int) {
        condition = min(condition + amount, 100)
    }
}

extension Player {
    var desc: String {
        var description = "\(fullName) (\(position))\n"
//        description += "Age: \(age), Height: \(feetToFeetInches(height)), Weight: \(weight) lbs\n"
//        description += "Condition: \(condition)%, Morale: \(morale)\n"
        description += "OVERALL: \(overallRating)\n"
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
