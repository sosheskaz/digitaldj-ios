//
//  SpotifyProfile.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/6/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import SpotifyAuthentication

class SpotifyProfile {
    let userId: String
    let songs: Array<String>
    
    init?(userId: String, songs: Array<String>) {
        self.userId = userId
        self.songs = songs
        
        if(self.userId == "" || self.songs.count <= 0) {
            return nil
        }
    }
}
