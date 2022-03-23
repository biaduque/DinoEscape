//
//  Music.swift
//  DinoEscape
//
//  Created by Raphael Alkamim on 23/03/22.
//

import Foundation
import AVFAudio

class MusicService: AudioDelegate {
    
    
    
    
    static let shared = MusicService()
    
    private var audioPlayer: AVAudioPlayer!
    
    
    func toggleMusic() -> SKButton {
        switch self.updateUserDefaults() {
        case true:
            self.soundManager(with: .gameMusic, soundAction: .play, .loop)
            button.updateImage(with: .musicOn)
        case false:
            self.soundManager(with: .gameMusic, soundAction: .pause, .loop)
            button.updateImage(with: .musicOff)
        }
    }
    
    func getUserDefaultsStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: "music")
    }
    
    func updateUserDefauts() -> Bool{
        var music = UserDefaults.standard.bool(forKey: "music")
        music.toggle()
        UserDefaults.standard.setValue(music, forKey: "music")
        return self.getUserDefaultsStatus()
    }
    
    func soundManager(with music: MusicType, action: SoundAction ) -> Void {
        
        let audio = self.getMusic(musicType: music)
        
        if let audio = audio {
            switch action {
            case .play:
                if UserDefaults.standard.bool(forKey: "music") {
                    audio.play()
                }
            case .pause:
                audio.stop()
            }
        }
    }
    
    func getMusic(musicType: MusicType) -> AVAudioPlayer? {
        if let music = self.audioPlayer {
            return music
        }
        
        if let musicFile = Bundle.main.path(forResource: musicType.rawValue , ofType: "mp3") {
            do {
                let music = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: musicFile))
                music.numberOfLoops = -1
                music.play()
                
                switch musicType {
                case.gameMusic:
                    music.volume = 1
                case.otherScenes:
                    music.volume = 0.5
                }
                
                return music
                
            } catch {
                print(error)
                return nil
            }
            
        }
        return nil
    }
    
    
    
}
