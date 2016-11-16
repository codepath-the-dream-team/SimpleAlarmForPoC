//
//  ViewController.swift
//  AnotherAlarm
//
//  Created by Chihiro Saito on 11/14/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import UIKit

class SleepViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var mediaTimeProgressView: UIProgressView!
    
    let mediaStopTimeInMinutes = 5 // stop in 5 minutes - CHANGME
    
    var sleepAlarm : AlarmObject?
    
    var currentMediaTime = 0 {
        didSet {
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds:currentMediaTime)
            timerLabel.text = String(format: "%02d:%02d:%02d", h,m,s)
            self.mediaTimeProgressView.setProgress(Float(currentMediaTime) / Float(mediaStopTimeInMinutes*60), animated: true)
        }
    }
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sleepPlayItem = Settings.getSleepPlayItem()
        self.sleepAlarm = AlarmObject(itemToPlay: sleepPlayItem.0)
        self.sleepAlarm!.setVolume(volume: self.volumeSlider.value)
        self.sleepAlarm!.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        
        self.songLabel.text = sleepPlayItem.1
        self.alarmButton.setTitle("Stop", for: UIControlState.selected)

        self.currentMediaTime = 0
        //self.onButtonClick(self.alarmButton) // auto play
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let alarm = self.sleepAlarm {
            alarm.stop()
            alarmButton.isSelected = false
        }
    }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        if let alarm = self.sleepAlarm {
            if alarm.status == AlarmObject.Status.started {
                alarm.stop()
            } else {
                alarm.startPlayback(duration: self.mediaStopTimeInMinutes)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
            }
            alarmButton.isSelected = (alarm.status == AlarmObject.Status.started)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Observe for the Alarm stopping.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "status") {
            if let alarm = object as? AlarmObject {
                if alarm == self.sleepAlarm! && alarm.status == AlarmObject.Status.stopped {
                    if let timer = timer {
                        timer.invalidate()
                    }
                    self.currentMediaTime = 0
                }
            }
        }
    }
    
    func timerFired() {
        self.currentMediaTime = self.sleepAlarm!.getElapsedTime()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func onVolumeSliderChanged(_ sender: UISlider) {
        self.sleepAlarm?.setVolume(volume: sender.value)
    }

}

