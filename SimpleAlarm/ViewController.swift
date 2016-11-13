//
//  ViewController.swift
//  SimpleAlarm
//
//  Created by Chihiro Saito on 11/12/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

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
    @IBOutlet weak var songLabel: UILabel!
    
    private let songNames = ["morning-forest", "babbling-brook", "rainy-day"]
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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayback,
                with: .defaultToSpeaker)
        } catch {
            print("Failed to set audio session category.  Error: \(error)")
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        content.sound = UNNotificationSound.default() // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger) // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
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
    
    func initPlayer(path: String) {
        let url = URL(string: path)
        let playerItem = AVPlayerItem(url: url!)
        self.player = AVPlayer(playerItem: playerItem)
        self.player.volume = 1.0
        // loop
        NotificationCenter.default.addObserver(self,
                                               selector: Selector(("playerItemDidReachEnd:")),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem)
    }
    
    func initPlayer(playerItems: [AVPlayerItem]) {
        self.player = AVPlayer(playerItem: playerItems[0])
        self.player.volume = 1.0
        self.songLabel.text = songNames[0]
        
        // loop
        NotificationCenter.default.addObserver(self,
                                                         selector: Selector(("playerItemDidReachEnd:")),
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
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }

}

