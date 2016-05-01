//
//  AlertPlayer.swift
//  GoodMorning
//
//  Created by Essi Vehmersalo on 01/05/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit
import AVFoundation

protocol AlertPlayerDelegate {
    func alertPlayingStopped()
}

class AlertPlayer: NSObject, AVAudioPlayerDelegate {
    var wakeUpPlayer: AVAudioPlayer?
    var delegate: AlertPlayerDelegate?
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer,
                                     successfully flag: Bool) {
        delegate?.alertPlayingStopped()
        
    }

    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        // not much to do here
        delegate?.alertPlayingStopped()
    }


    func playWakeUp() {
        let path = NSBundle.mainBundle().pathForResource("246390__foolboymedia__chiming-out.wav", ofType:nil)!
        let url = NSURL(fileURLWithPath: path)
        
        do {
            wakeUpPlayer = try AVAudioPlayer(contentsOfURL: url)
            wakeUpPlayer?.delegate = self
            wakeUpPlayer?.play()
        } catch {
            // couldn't load file
            delegate?.alertPlayingStopped()
        }
    }
    
    func stopWakeUpPlayer() {
        if wakeUpPlayer != nil && wakeUpPlayer!.playing {
            wakeUpPlayer?.stop()
            delegate?.alertPlayingStopped()
        }
    }

}