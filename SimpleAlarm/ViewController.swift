//
//  ViewController.swift
//  AnotherAlarm
//
//  Created by Chihiro Saito on 11/14/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    
    var player = AVPlayer()
    var alarmScheduled = false
    let alarmDuration = 1 // 10 seconds
    var countdown = 0 {
        didSet {
            self.setTimerCountdownLabel(countdown)
        }
    }
    var timer : Timer?
    private let songNames = ["rainy-day", "babbling-brook", "morning-forest"]
    private lazy var songs: [AVPlayerItem] = {
        return self.songNames.map {
            let url = Bundle.main.url(forResource: "Sounds/\($0)", withExtension: "mp3")!
            return AVPlayerItem(url: url)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmButton.setTitle("Stop Alarm", for: UIControlState.selected)
        self.initPlayer(playerItems: self.songs)
        //self.initPlayer(path: self.mp3path)
        self.countdown = self.alarmDuration
    }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        if (!alarmScheduled) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        } else {
            if (countdown > 0) {
                self.timer!.invalidate()
            } else {
                self.player.pause()
                self.countdown = self.alarmDuration
            }
        }
        alarmScheduled = !alarmScheduled
        alarmButton.isSelected = alarmScheduled
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPlayer(playerItems: [AVPlayerItem]) {
        self.player = AVPlayer(playerItem: playerItems[0])
        self.player.volume = 1.0
        self.songLabel.text = songNames[0]
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ViewController.playerItemReachedToEnd),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: self.player.currentItem)
    }
    
    func timerFired() {
        countdown -= 1
        if (countdown == 0) {
            self.timer!.invalidate()
            self.player.play()
        }
        if UIApplication.shared.applicationState != .active {
            print("Background: \(countdown)")
        }
    }
    
    func setTimerCountdownLabel(_ seconds: Int) {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds:seconds)
        timerLabel.text = String(format: "%02d:%02d:%02d", h,m,s)
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func playerItemReachedToEnd(notification: NSNotification) {
        self.player.seek(to: CMTimeMakeWithSeconds(1, 1))
        self.player.play()
    }


}

