//
//  DataStore.swift
//  Sports
//
//  Created by Wesley St. John on 2/20/22.
//

import Foundation
import UIKit

class DataStore {

    private let defaults = UserDefaults(suiteName: "com.sports.DataStore")
    private var playerFaces = NSCache<NSString, UIImage>()
    private let savedLeagueKey = "savedLeague"
    private let leagueKeyPrefix = "league-"
    private let playerImageKeyPrefix = "playerImage-"

    func loadLastLeagueSave() -> LeagueSave? {
        guard let defaults = defaults,
              let data = defaults.data(forKey: savedLeagueKey) else {
                  return nil
              }

        do {
            let decoder = JSONDecoder()
            let savedLeague = try decoder.decode(LeagueSave.self, from: data)
            return savedLeague

        } catch {
            print("Unable to Decode LeagueSave (\(error))")
            return nil
        }
    }

    func storeLeagueSave(_ leagueSave: LeagueSave) {
        guard let defaults = defaults else { return }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(leagueSave)
            defaults.set(data, forKey: savedLeagueKey)
        } catch {
            print("Unable to Encode LeagueSave (\(error))")
        }
    }

    func loadLeague(withID id: String) -> League? {
        let key = leagueKeyPrefix + id
        guard let defaults = defaults,
              let data = defaults.data(forKey: key) else {
                  return nil
              }

        do {
            let decoder = JSONDecoder()
            let league = try decoder.decode(League.self, from: data)
            return league

        } catch {
            print("Unable to Decode League (\(error))")
            return nil
        }
    }

    func saveLeague(_ league: League) {
        guard let defaults = defaults else { return }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(league)
            let key = leagueKeyPrefix + league.id
            defaults.set(data, forKey: key)

            let leagueSave = LeagueSave(id: league.id, name: league.name)
            storeLeagueSave(leagueSave)
        } catch {
            print("Unable to Encode League (\(error))")
        }

    }

    func getPlayerImage(_ player: Player, from team: Team?) -> UIImage? {
        let id = player.id
        if let cachedFace = loadCachedPlayerImage(withID: id) {
            return cachedFace

        } else if let storedFace = loadStoredPlayerImage(withID: id) {
            cachePlayerImage(storedFace, withID: id)
            return storedFace

        } else {
            var primaryColor = team?.primaryColor.uiColor ?? .black
            var secondaryColor = team?.secondaryColor.uiColor ?? .white
            if player.position == .keeper {
                primaryColor = .keeperHomeColor
                secondaryColor = .white
            }
            let generatedFace = FaceFactory.makeFace(teamPrimaryColor: primaryColor,
                                                     teamSecondaryColor: secondaryColor)
            cachePlayerImage(generatedFace, withID: id)
            storePlayerImage(generatedFace, withID: id)
            return generatedFace
        }
    }
}

extension DataStore {
    private func loadCachedPlayerImage(withID id: String) -> UIImage? {
        let key = NSString(string: playerImageKeyPrefix + id)
        return playerFaces.object(forKey: key)
    }

    private func cachePlayerImage(_ image: UIImage, withID id: String) {
        let key = NSString(string: playerImageKeyPrefix + id)
        playerFaces.setObject(image, forKey: key)
    }

    private func loadStoredPlayerImage(withID id: String) -> UIImage? {
        let key = playerImageKeyPrefix + id
        guard let defaults = defaults,
              let data = defaults.data(forKey: key) else {
                  return nil
              }
        return UIImage(data: data)
    }

    private func storePlayerImage(_ image: UIImage, withID id: String) {
        guard let defaults = defaults,
              let data = image.pngData() else {
                  return
              }

        let key = playerImageKeyPrefix + id
        defaults.set(data, forKey: key)
    }
}

class LeagueSave: NSObject, Codable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
