//
//  SequencePlayer.swift
//  AudioTest
//
//  Created by Wesley St. John on 5/11/22.
//

import AVFoundation

class SequencePlayer: NSObject {

    private var player: AVAudioPlayer?
    private var soundAssetNames: [String] = []

    init(soundAssetNames: [String]) {
        self.soundAssetNames = soundAssetNames
    }

    func play() {
        playNextSound()
    }

    private func playNextSound() {
        guard let name = soundAssetNames.first,
              let path = Bundle.main.path(forResource: name, ofType: "caf") else {
                  return
              }

        let url = URL(fileURLWithPath: path)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension SequencePlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        soundAssetNames.remove(at: 0)
        if !soundAssetNames.isEmpty {
            playNextSound()
        }
    }
}


class SequencePlayerNoDelegate: NSObject {

    private var player: AVAudioPlayer?
    private var soundAssetNames: [String] = []

    init(soundAssetNames: [String]) {
        self.soundAssetNames = soundAssetNames
    }

    func play() {
        playNextSound()
    }

    private func playNextSound() {
        guard let name = soundAssetNames.first,
              let path = Bundle.main.path(forResource: name, ofType: "caf") else {
                  return
              }

        let url = URL(fileURLWithPath: path)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)

            DispatchQueue.main.asyncAfter(deadline: .now() + (player?.duration ?? 0.0)) {
                self.soundAssetNames.remove(at: 0)
                if !self.soundAssetNames.isEmpty {
                    self.playNextSound()
                }
            }

            player?.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}


class SequencePlayerCaching: NSObject {

    private var players: [AVAudioPlayer] = []

    init(soundAssetNames: [String]) {
        super.init()

        for name in soundAssetNames {
            if let player = loadSound(named: name) {
                players.append(player)
            }
        }
    }

    func play() {
        playAllSounds()
    }

    private func loadSound(named name: String) -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: name, ofType: "caf") else {
                  return nil
              }

        let url = URL(fileURLWithPath: path)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player

        } catch let error {
            print(error.localizedDescription)
        }

        return nil
    }

    private func playAllSounds() {
        var delay = 0.0
        for player in players {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                player.play()
            }
            delay += player.duration - 0.15
        }
    }
}

//extension SequencePlayerCaching: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        players.remove(at: 0)
//        if !players.isEmpty {
//            playNextSound()
//        }
//    }
//}
