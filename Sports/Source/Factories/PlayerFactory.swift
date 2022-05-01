//
//  PlayerFactory.swift
//  Sports
//
//  Created by Wesley St. John on 12/21/21.
//

import Foundation

class PlayerFactory {

    static func makePlayer(position: Position = .forward) -> Player {

        let ratings = makeRatings(position: position)
        let potential = makePotential(from: ratings, at: position)
        let xpLevel = makeXpLevel(from: ratings, at: position)
        return Player(id: UUID().uuidString,
                      firstName: NameFactory.makeFirstName(),
                      lastName: NameFactory.makeLastName(),
                      height: makeHeight(position: position),
                      weight: makeWeight(position: position),
                      position: position,
                      age: makeAge(),
                      morale: makeMorale(),
                      contract: makeContract(ratings: ratings),
                      teamId: nil,
                      jerseyNumber: makeJerseyNumber(),
                      isCaptain: false,
                      ratings: ratings,
                      potential: potential,
                      xp: Int.random(in: 0..<100),
                      xpLevel: xpLevel)
    }

}

extension PlayerFactory {

    private static func makeHeight(position: Position) -> Double {
        switch position {
        case .keeper: return .random(in: 5.75 ..< 6.75)
        case .defender: return .random(in: 5.75 ..< 6.75)
        case .midfielder: return .random(in: 5.5 ..< 6.5)
        case .forward: return .random(in: 5.5 ..< 6.25)
        }
    }

    private static func makeWeight(position: Position) -> Int {
        switch position {
        case .keeper: return .random(in: 160 ..< 225)
        case .defender: return .random(in: 175 ..< 220)
        case .midfielder: return .random(in: 160 ..< 200)
        case .forward: return .random(in: 150 ..< 190)
        }
    }

    private static func makeAge() -> Int {
        return .random(in: 16 ..< 42)
    }

    private static func makeMorale() -> Player.Morale {
        return Player.Morale.allCases.randomElement() ?? .ok
    }

    private static func makeContract(ratings: Player.Ratings) -> Player.Contract {
//        var salary: Int
//        switch ratings.overall {
//        case 90...100: salary = .random(in: 30 ... 75)
//        case 85..<90: salary = .random(in: 20 ... 30)
//        case 80..<85: salary = .random(in: 10 ... 20)
//        case 75..<80: salary = .random(in: 5 ... 10)
//        default: salary = .random(in: 1 ... 5)
//        }
//        return .init(duration: .random(in: 1 ... 4),
//                     salary: salary)
        return .init(duration: 2, salary: 1000000)
    }

    private static func makeJerseyNumber() -> Int {
        return .random(in: 0...99)
    }
}

extension PlayerFactory {
    static func makeRatings(position: Position) -> Player.Ratings {
        switch position {
        case .keeper: return makeKeeperRating()
        case .defender: return makeDefenderRating()
        case .midfielder: return makeMidfielderRating()
        case .forward: return makeForwardRating()
        }
    }

    private static func makeKeeperRating() -> Player.Ratings {
        let speed = Int.random(in: 20 ..< 60)
        let shooting = Int.random(in: 20 ..< 50)
        let passing = Int.random(in: 40 ..< 80)
        let dribbling = Int.random(in: 20 ..< 60)
        let defending = Int.random(in: 55 ..< 100)
        let goalkeeping = Int.random(in: 60 ..< 100)

        return .init(speed: speed,
                     shooting: shooting,
                     passing: passing,
                     dribbling: dribbling,
                     defending: defending,
                     goalkeeping: goalkeeping)
    }

    private static func makeDefenderRating() -> Player.Ratings {
        let speed = Int.random(in: 45 ..< 95)
        let shooting = Int.random(in: 30 ..< 75)
        let passing = Int.random(in: 50 ..< 95)
        let dribbling = Int.random(in: 40 ..< 90)
        let defending = Int.random(in: 55 ..< 100)
        let goalkeeping = Int.random(in: 20 ..< 40)

        return .init(speed: speed,
                     shooting: shooting,
                     passing: passing,
                     dribbling: dribbling,
                     defending: defending,
                     goalkeeping: goalkeeping)
    }

    private static func makeMidfielderRating() -> Player.Ratings {
        let speed = Int.random(in: 50 ..< 95)
        let shooting = Int.random(in: 50 ..< 100)
        let passing = Int.random(in: 55 ..< 100)
        let dribbling = Int.random(in: 50 ..< 95)
        let defending = Int.random(in: 50 ..< 95)
        let goalkeeping = Int.random(in: 20 ..< 40)

        return .init(speed: speed,
                     shooting: shooting,
                     passing: passing,
                     dribbling: dribbling,
                     defending: defending,
                     goalkeeping: goalkeeping)
    }

    private static func makeForwardRating() -> Player.Ratings {
        let speed = Int.random(in: 55 ..< 100)
        let shooting = Int.random(in: 50 ..< 100)
        let passing = Int.random(in: 45 ..< 100)
        let dribbling = Int.random(in: 50 ..< 100)
        let defending = Int.random(in: 20 ..< 70)
        let goalkeeping = Int.random(in: 20 ..< 30)

        return .init(speed: speed,
                     shooting: shooting,
                     passing: passing,
                     dribbling: dribbling,
                     defending: defending,
                     goalkeeping: goalkeeping)
    }
}

extension PlayerFactory {
    private static func makePotential(from ratings: Player.Ratings,
                                      at position: Position) -> Player.Ratings {

        let avgGrowth = potentialGrowth(currentRating: ratings.getOverall(for: position))
        let potentialSpeed = min(99, ratings.speed + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))
        let potentialShooting = min(99, ratings.shooting + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))
        let potentialPassing = min(99, ratings.passing + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))
        let potentialDribbling = min(99, ratings.dribbling + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))
        let potentialDefending = min(99, ratings.defending + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))
        let potentialGoalkeeping = min(99, ratings.goalkeeping + avgGrowth + Int.random(in: -avgGrowth/3...avgGrowth/3))

        return .init(speed: potentialSpeed,
                     shooting: potentialShooting,
                     passing: potentialPassing,
                     dribbling: potentialDribbling,
                     defending: potentialDefending,
                     goalkeeping: potentialGoalkeeping)
    }

    private static func potentialGrowth(currentRating: Int) -> Int {
        // maxGrowth = 20
        // max at 60 or less
        // zero growth possible at ~95
        let maxPossibleGrowth = 20.0
        let slope = -0.57
        let intercept = 54.0
        var maxPotentialGrowth = min(Double(currentRating) * slope + intercept, maxPossibleGrowth)
        maxPotentialGrowth = max(maxPotentialGrowth, 0)

        return Int.random(in: 0...Int(maxPotentialGrowth))
    }
}

extension PlayerFactory {
    private static func makeXpLevel(from ratings: Player.Ratings, at position: Position) -> Int {
        switch ratings.getOverall(for: position) {
        case Int.min..<65: return 1
        case 65..<70: return Int.random(in: 1...2)
        case 70..<75: return Int.random(in: 1...4)
        case 75..<80: return Int.random(in: 4...6)
        case 80..<85: return Int.random(in: 5...9)
        default: return Int.random(in: 8...12)
        }
    }
}
