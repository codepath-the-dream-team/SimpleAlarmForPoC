//
//  Playlist.swift
//  SimpleAlarm
//
//  Created by Chihiro Saito on 11/15/16.
//  Copyright © 2016 Chihiro Saito. All rights reserved.
//

import Foundation

class Settings {
    
    private static let sleepSong = "owls-and-crickets"
    private static let alarmSong = "morning-forest"
    
    static func getSleepPlayItem() -> (URL, String) {
        let url = Bundle.main.url(forResource: "Sounds/\(sleepSong)", withExtension: "mp3")!
        return (url, sleepSong)
    }
    
    static func getMorningPlayItem() -> (URL, String) {
        let url = Bundle.main.url(forResource: "Sounds/\(alarmSong)", withExtension: "mp3")!
        return (url, alarmSong)
    }
}
