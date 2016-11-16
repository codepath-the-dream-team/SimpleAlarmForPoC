//
//  AlarmViewController.swift
//  SimpleAlarm
//
//  Created by Chihiro Saito on 11/15/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import UIKit
import AVFoundation

class AlarmViewController: UIViewController {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var mediaTimeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var maxVolumeLabel: UILabel!
    @IBOutlet weak var alarmScheduleLabel: UILabel!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    var toMaxVolumeInMinutes = 2 // Max volume in 2 minutes - CHANGEME
    var alarmScheduleAt = Date(timeIntervalSinceNow: 60) // Start alarm 60 seconds from now - CHANGEME
    
    var wakeupAlarm: AlarmObject?
    
    var currentMediaTime = 0 {
        didSet {
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds:currentMediaTime)
            mediaTimeLabel.text = String(format: "%02d:%02d:%02d", h,m,s)
        }
    }
    var currentTime = Date() {
        didSet {
            currentTimeLabel.text = self.dateFormatter.string(from: currentTime as Date)
        }
    }
    let dateFormatter = DateFormatter()
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let morningPlayItem = Settings.getMorningPlayItem()
        self.wakeupAlarm = AlarmObject(itemToPlay: morningPlayItem.0)
        self.wakeupAlarm!.setVolume(volume: 0.1)
        self.wakeupAlarm!.setVolumeIncreaseFeature(toMaxVolumeInMinutes: toMaxVolumeInMinutes)
        self.wakeupAlarm!.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        self.songNameLabel.text = morningPlayItem.1
        
        self.startButton.setTitle("Cancel", for: UIControlState.selected)
        self.dateFormatter.dateFormat = "HH:mm:ss"
        self.currentTime = Date(timeIntervalSinceNow: 0)
        
        self.maxVolumeLabel.text = "\(self.toMaxVolumeInMinutes) minutes to maximum volume"
        self.alarmScheduleLabel.text = "Alarm starts at " + self.dateFormatter.string(from: self.alarmScheduleAt)
        //self.onButtonClick(self.startButton) // auto play

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let alarm = self.wakeupAlarm {
            alarm.stop()
            startButton.isSelected = false
        }
    }
    
    // Observe for the Alarm status change.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "status") {
            if let alarm = object as? AlarmObject {
                if alarm == self.wakeupAlarm! && alarm.status == AlarmObject.Status.stopped {
                    self.addTextToStatusArea("Alarm stop detected")
                    self.currentMediaTime = 0
                }
            }
        }
    }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        if let alarm = self.wakeupAlarm {
            if (alarm.status == AlarmObject.Status.initialized || alarm.status == AlarmObject.Status.stopped) {
                alarm.scheduleAt(when: self.alarmScheduleAt as Date)
                self.addTextToStatusArea("Scheduled alarm at " + self.dateFormatter.string(from: alarmScheduleAt as Date))
            } else {
                alarm.stop()
                self.addTextToStatusArea("Stopped alarm")
            }
            startButton.isSelected = (alarm.status == AlarmObject.Status.scheduled || alarm.status == AlarmObject.Status.started)
        }
    }
    
    func timerFired() {
        self.currentMediaTime = self.wakeupAlarm!.getElapsedTime()
        self.currentTime = Date()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func addTextToStatusArea(_ text: String) {
        //self.statusTextView.insertText(text)
        //self.statusTextView.insertText("\n")
    }
}
