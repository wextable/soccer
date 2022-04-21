//
//  Team.swift
//  Sports
//
//  Created by Wesley St. John on 12/22/21.
//

import UIKit

class Team: NSObject, Codable {

    let id: String
    let name: String
    let longName: String
    let shortName: String
    let nickName: String
    let iconName: String?
    var icon: UIImage? {
        guard let iconName = iconName else { return nil }
        return UIImage(named: iconName)
    }
    let primaryColor: CodableColor
    let secondaryColor: CodableColor

    var prestige: String
    var players: [Player]
    var ratings: Ratings {
        return .init(goalkeeping: keepers.map({ $0.ratings.overall }).reduce(0, +) / keepers.count,
                     defense: defenders.map({ $0.ratings.overall }).reduce(0, +) / defenders.count,
                     midfield: midfielders.map({ $0.ratings.overall }).reduce(0, +) / midfielders.count,
                     forwards: forwards.map({ $0.ratings.overall }).reduce(0, +) / forwards.count,
                     overall: players.map({ $0.ratings.overall }).reduce(0, +) / players.count)
    }

    var wins: Int = 0
    var draws: Int = 0
    var losses: Int = 0
    var ranking: Int = 1

    var goalsFor: Int = 0
    var goalsAgainst: Int = 0

    var schedule: [Game?] = []

    init(id: String,
         name: String,
         longName: String,
         shortName: String,
         nickName: String,
         iconName: String?,
         primaryColor: UIColor,
         secondaryColor: UIColor,
         prestige: String,
         players: [Player]) {
        self.id = id
        self.name = name
        self.longName = longName
        self.shortName = shortName
        self.nickName = nickName
        self.iconName = iconName
        self.primaryColor = CodableColor(color: primaryColor)
        self.secondaryColor = CodableColor(color: secondaryColor)
        self.prestige = prestige
        self.players = players
    }
}

extension Team {
    var keepers: [Player] { players.filter { $0.position == .keeper } }
    var defenders: [Player] { players.filter { $0.position == .defender } }
    var midfielders: [Player] { players.filter { $0.position == .midfielder } }
    var forwards: [Player] { players.filter { $0.position == .forward } }
}

extension Team {
    var points: Int {
        return wins * 3 + draws
    }
}

extension Team {
    struct Ratings: Equatable, Codable {
        var goalkeeping: Int
        var defense: Int
        var midfield: Int
        var forwards: Int

        var overall: Int
    }

    var scoringRating: Int {
        let ratingOffset = 40
        let ratingExponent = 1.22

        var rating = 0
        var totalWeight = 0.0

        let forwardWeight = 2.75
        for f in forwards {
            if f.ratings.overallScoring > ratingOffset {
                rating += Int(pow(Double(f.ratings.overallScoring - ratingOffset), ratingExponent) * forwardWeight)
            }
            totalWeight += forwardWeight
        }

        let midfielderWeight = 2.0
        for m in midfielders {
            if m.ratings.overallScoring > ratingOffset {
                rating += Int(pow(Double(m.ratings.overallScoring - ratingOffset), ratingExponent) * midfielderWeight)
            }
            totalWeight += midfielderWeight
        }

        let defenderWeight = 1.25
        for d in defenders {
            if d.ratings.overallScoring > ratingOffset {
                rating += Int(pow(Double(d.ratings.overallScoring - ratingOffset), ratingExponent) * defenderWeight)
            }
            totalWeight += defenderWeight
        }

        return Int(Double(rating) / 20.0) //totalWeight)
    }

    var scoringRatingOLD: Int {
        var rating = 0
        var totalWeight = 0.0

        let forwardWeight = 2.75
        for f in forwards {
            //            print("Forward \(f.firstName) \(f.lastName) = \(f.ratings.overallScoring)")
            rating += Int(Double(f.ratings.overallScoring) * forwardWeight)
            totalWeight += forwardWeight
        }

        let midfielderWeight = 2.0
        for m in midfielders {
            //            print("Mid \(m.firstName) \(m.lastName) = \(m.ratings.overallScoring)")
            rating += Int(Double(m.ratings.overallScoring) * midfielderWeight)
            totalWeight += midfielderWeight
        }

        let defenderWeight = 1.25
        for d in defenders {
            //            print("Def \(d.firstName) \(d.lastName) = \(d.ratings.overallScoring)")
            rating += Int(Double(d.ratings.overallScoring) * defenderWeight)
            totalWeight += defenderWeight
        }

        return Int(Double(rating) / totalWeight)
    }

    var defensiveRating: Int {
        let ratingOffset = 40
        let ratingExponent = 1.22

        var rating = 0
        var totalWeight = 0.0

        let forwardWeight = 1.25
        for f in forwards {
            if f.ratings.overallDefensive > ratingOffset {
                rating += Int(pow(Double(f.ratings.overallDefensive - ratingOffset), ratingExponent) * forwardWeight)
            }
            totalWeight += forwardWeight
        }

        let midfielderWeight = 2.0
        for m in midfielders {
            if m.ratings.overallDefensive > ratingOffset {
                rating += Int(pow(Double(m.ratings.overallDefensive - ratingOffset), ratingExponent) * midfielderWeight)
            }
            totalWeight += midfielderWeight
        }

        let defenderWeight = 2.75
        for d in defenders {
            if d.ratings.overallDefensive > ratingOffset {
                rating += Int(pow(Double(d.ratings.overallDefensive - ratingOffset), ratingExponent) * defenderWeight)
            }
            totalWeight += defenderWeight
        }

        let keeperWeight = 4.0
        for k in keepers {
            if k.ratings.overall > ratingOffset {
                rating += Int(pow(Double(k.ratings.overall - ratingOffset), ratingExponent) * keeperWeight)
            }
            totalWeight += keeperWeight
        }

        return Int(Double(rating) / totalWeight)
    }

    var defensiveRatingOLD: Int {
        var rating = 0
        var totalWeight = 0.0

        let forwardWeight = 1.25
        for f in forwards {
            //            print("Forward \(f.firstName) \(f.lastName) = \(f.ratings.overallDefensive)")
            rating += Int(Double(f.ratings.overallDefensive) * forwardWeight)
            totalWeight += forwardWeight
        }

        let midfielderWeight = 2.0
        for m in midfielders {
            //            print("Mid \(m.firstName) \(m.lastName) = \(m.ratings.overallDefensive)")
            rating += Int(Double(m.ratings.overallDefensive) * midfielderWeight)
            totalWeight += midfielderWeight
        }

        let defenderWeight = 2.75
        for d in defenders {
            //            print("Def \(d.firstName) \(d.lastName) = \(d.ratings.overallDefensive)")
            rating += Int(Double(d.ratings.overallDefensive) * defenderWeight)
            totalWeight += defenderWeight
        }

        let keeperWeight = 4.0
        for k in keepers {
            rating += Int(Double(k.ratings.overall) * keeperWeight)
            totalWeight += keeperWeight
        }

        return Int(Double(rating) / totalWeight)
    }

    var offensiveStarRating: Double {
        return overallStarRating(overall: scoringRating)
    }

    var defensiveStarRating: Double {
        return overallStarRating(overall: defensiveRating)
    }

    private func overallStarRating(overall: Int) -> Double {
        switch overall {
        case Int.min..<61: return 0.5
        case 61..<63: return 1.0
        case 63..<65: return 1.5
        case 65..<67: return 2.0
        case 67..<70: return 2.5
        case 70..<73: return 3.0
        case 73..<76: return 3.5
        case 76..<79: return 4.0
        case 79..<82: return 4.5
        default: return 5.0
        }
    }
}

extension Team {
    var desc: String {
        var description = "\n"
        description += "TEAM: \(longName) \(nickName)\n"
        description += "Goalkeeping: \(ratings.goalkeeping)\n"
        description += "Defense: \(ratings.defense)\n"
        description += "Midfield: \(ratings.midfield)\n"
        description += "Forwards: \(ratings.forwards)\n"
        description += "OFF: \(scoringRating)\n"
        description += "DEF: \(defensiveRating)\n"
        description += "Overall: \(ratings.overall)\n"
//        description += "ROSTER:\n"
//        for p in players {
//            description += p.desc + "\n"
//        }
        return description
    }

    var recordDesc: String {
        return "(\(wins)-\(draws)-\(losses)), Goals: \(goalsFor), Goals Against: \(goalsAgainst)"
    }
}

struct CodableColor: Codable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat

    var uiColor: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(r: r, g: g, b: b, a: a)
    }
}

extension CodableColor {
    static let white: CodableColor = .init(r: 1, g: 1, b: 1)
    static let black: CodableColor = .init(r: 0, g: 0, b: 0)
}
