//
//  Scheduler.swift
//  Sports
//
//  Created by Wesley St. John on 2/20/22.
//

import Foundation

class Scheduler {

}

extension Scheduler {
    static func seasonPairings(teamIds: [String?], numRematches: Int = 1) -> [[(String?, String?)]] {
        var teamIds = teamIds
        if teamIds.count % 2 == 1 {
            teamIds.append(nil)
        }

        var tournament: [[(String?, String?)]] = []

        let half = teamIds.count/2
        var groupA: [String?] = Array(teamIds.prefix(half))
        var groupB: [String?] = Array(teamIds.suffix(half)).reversed()

        tournament.append(weeklyPairings(groupA: groupA, groupB: groupB))

        for _ in 1..<teamIds.count-1 {
            let lastTeamA = groupA.popLast()!
            let firstTeamB = groupB.remove(at: 0)
            groupA.insert(firstTeamB, at: 1)
            groupB.append(lastTeamA)

            tournament.append(weeklyPairings(groupA: groupA, groupB: groupB))
        }

        // Each team plays each other numRematches+1 times
        for _ in 0..<numRematches {
            tournament.append(contentsOf: tournament)
        }

        return tournament
    }

    private static func weeklyPairings(groupA: [String?], groupB: [String?]) -> [(String?, String?)] {
        var total: [(String?, String?)] = []
        for i in 0..<groupA.count {
            if i % 2 == 0 {
                total.append((groupA[i], groupB[i]))
            } else {
                total.append((groupB[i], groupA[i]))
            }
        }
        return total
    }
}
