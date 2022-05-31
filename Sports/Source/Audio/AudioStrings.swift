//
//  PlayerNameAudio.swift
//  AudioTest
//
//  Created by Wesley St. John on 5/11/22.
//

import Foundation

protocol AudioString {
    var soundNames: [String] { get }
}

protocol PlayerName {
    var firstName: String { get }
    var lastName: String { get }
}

struct PassCommentary: AudioString {

    private(set) var soundNames: [String]

    init(from: PlayerName, to: PlayerName) {
        let fromSounds = PlayerNameAudio(playerName: from).soundNames
        let toSounds = PlayerNameAudio(playerName: to).soundNames

        let phrase = PassPhrase.allCases.randomElement()!
        switch phrase {
        case .from:
            soundNames = fromSounds + phrase.soundNames
        case .fromTo:
            soundNames = fromSounds + phrase.soundNames + toSounds
        case .generic:
            soundNames = phrase.soundNames
        case .to:
            soundNames = phrase.soundNames + toSounds
        case .toFrom:
            soundNames = fromSounds + phrase.soundNames + toSounds

        }
    }
}

struct PlayerNameAudio: AudioString {

    private(set) var soundNames: [String]

    private let testNames = [
        "queef",
        "johnson",
        "scaramucci",
        "chode",
        "jeremy",
        "magnusson",
        "pistacio",
        "buckwalter"
    ]

    init(playerName: PlayerName) {
        if Int.random(in: 0..<100) < 80 {
            soundNames = [testNames.randomElement()!] //[playerName.lastName]
        } else {
            soundNames = [testNames.randomElement()!, testNames.randomElement()!] //[playerName.firstName, playerName.lastName]
        }
    }
}

enum PassPhrase: AudioString, CaseIterable {
    case from
    case fromTo
    case generic
    case to
    case toFrom

    private var phrases: [String] {
        switch self {
        case .from:
            return ["passes_the_ball", ""]
        case .fromTo:
            return ["passes_to", "gives_it_to"]
        case .generic:
            return ["opportunity_here", "great_ball"]
        case .to:
            return ["pass_to", "hes_got", "he_sees"]
        case .toFrom:
            return ["gets_it_from", "beautiful_pass_from"]

        }
    }

    var soundNames: [String] {
        return [phrases.randomElement()!]
    }
}
