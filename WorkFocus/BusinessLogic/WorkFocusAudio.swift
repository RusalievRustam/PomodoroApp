//
//  Untitled.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 19/12/24.
//

import Foundation
import AVFoundation

enum WorkFocusAudioSounds{
    case done
    
    
    var resource: String{
        switch self{
        case .done:
            return "bell.wav"
        }
    }
}
class WorkFocusAudio{
    private var _audioPlayer: AVAudioPlayer?
      
    func play(_ sound: WorkFocusAudioSounds) {
        let path = Bundle.main.path(forResource: sound.resource, ofType: nil)!
        let url = URL(filePath: path)
        
        do {
          _audioPlayer = try AVAudioPlayer(contentsOf: url)
          _audioPlayer?.play()
        } catch {
          print(error.localizedDescription)
        }
        
 }
}
