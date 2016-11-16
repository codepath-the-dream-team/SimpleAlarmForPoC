//
//  AlarmObject.swift
//  SimpleAlarm
//

import Foundation
import AVFoundation

class AlarmObject : NSObject {
    
    dynamic var status = Status.initialized

    var player = AVPlayer()
    var toMaxVolumeInMinutes = -1
    var mediaStopTimeInMinutes = -1
    var currentMediaTime = 0
    var timer : Timer?
    var volumeInterval = 0
    
    init(itemToPlay: URL) {
        super.init()
        self.player = AVPlayer(playerItem: AVPlayerItem(url: itemToPlay))
        self.player.volume = 1.0
        self.currentMediaTime = 0
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemReachedToEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem)
    }
    
    func setVolumeIncreaseFeature(toMaxVolumeInMinutes: Int) {
        print("[AO] setVolumeIncreaseFeature max in \(toMaxVolumeInMinutes) minutes")
        self.toMaxVolumeInMinutes = toMaxVolumeInMinutes;
    }
    
    func scheduleAt(when: Date) {
        print("[AO] scheduleAlarmAt \(when)")
        if (self.status == Status.started || self.status == Status.scheduled) {
            print("[AO] Error: Alarm currently active, call stop() first.")
            return
        }
        let delay = when.timeIntervalSinceNow
        if (delay < 0) {
            // time given is earlier than now - start timer immediately
            startPlayback(duration: -1)
        } else {
            self.perform(#selector(self.startPlayback), with: nil, afterDelay: delay)
            self.status = Status.scheduled
        }
    }
    
    func startPlayback(duration: Int) {
        print("[AO] alarm started \(Date())")
        self.player.play()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        if self.toMaxVolumeInMinutes > 0 {
            self.volumeInterval = self.toMaxVolumeInMinutes * 60 / Int((1.0 - (self.player.volume)) * 10)
            print("[AO] alarm volume interval \(self.volumeInterval)")
            
        } else {
            self.volumeInterval = 0
        }
        if duration > 0 {
            self.mediaStopTimeInMinutes = duration
        }
        self.status = Status.started
    }
    
    func stop() {
        print("[AO] stopping alarm \(Date())")
        if self.status == Status.scheduled {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        } else if self.status == Status.started {
            self.player.pause()
        }
        if let timer = timer {
            timer.invalidate()
        }
        self.currentMediaTime = 0
        self.status = Status.stopped
    }
    
    func setVolume(volume: Float) {
        print("[AO] setting volume \(volume) \(Date())")
        if volume <= 1.0 && volume >= 0.0 {
            self.player.volume = volume
        }
    }
    
    func playerItemReachedToEnd(notification: NSNotification) {
        print("[AO] end reached, looping")
        self.player.seek(to: CMTimeMakeWithSeconds(1, 1))
        self.player.play()
    }
    
    func timerFired() {
        self.currentMediaTime += 1
        if (self.volumeInterval > 0 && self.currentMediaTime % self.volumeInterval == 0) {
            self.setVolume(volume: player.volume + 0.1)
        }
        if (self.mediaStopTimeInMinutes > 0 && self.currentMediaTime >= self.mediaStopTimeInMinutes*60) {
            self.stop()
        }
    }
    
    func getElapsedTime() -> Int {
        return self.currentMediaTime
    }
    
    func getPlayer() -> AVPlayer {
        return self.player
    }
    
    @objc
    enum Status: Int {
        case initialized = 0,
        scheduled = 1,
        started = 2,
        stopped = 3
    }
}
