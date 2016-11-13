//
//  ViewController.swift
//  SimpleAlarm
//
//  Created by Chihiro Saito on 11/12/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    
    let mp3path = "https://dream-team-bucket.s3-us-west-1.amazonaws.com/music/rainforest.mp3"
    var player = AVPlayer()
    var alarmScheduled = false
    let alarmDuration = 10 // 10 seconds
    var countdown = 0 {
        didSet {
            self.setTimerCountdownLabel(countdown)
        }
    }
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmButton.setTitle("Stop Alarm", for: UIControlState.selected)
        self.initPlayer(self.mp3path)
        self.countdown = self.alarmDuration
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func initPlayer(_ path: String) {
        let url = URL(string: path)
        let playerItem = AVPlayerItem(url: url!)
        self.player = AVPlayer(playerItem: playerItem)
        self.player.volume = 1.0
    }
    
    func timerFired() {
        countdown -= 1
        if (countdown == 0) {
            self.timer!.invalidate()
            self.player.play()
        }
    }
    
    func setTimerCountdownLabel(_ seconds: Int) {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds:seconds)
        timerLabel.text = String(format: "%02d:%02d:%02d", h,m,s)
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}

