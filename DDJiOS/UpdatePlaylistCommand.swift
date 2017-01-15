//
//  UpdatePlaylistCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

private let currentlyPlayingLabel: String = "currentlyPlaying"
private let queueLabel: String = "queue"

class UpdatePlaylistCommand: HostClientCommand {
    static var command: String = "updatePlaylist"
    var currentlyPlaying: String
    var queue: Array<String>
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: UpdatePlaylistCommand.command as AnyObject,
             currentlyPlayingLabel: self.currentlyPlaying as AnyObject,
             queueLabel: self.queue as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
    
    init(currentlyPlaying: String, queue: Array<String>) {
        self.currentlyPlaying = currentlyPlaying
        self.queue = queue
    }
    
    init(fullQueue: Array<String>) {
        self.currentlyPlaying = fullQueue[0]
        self.queue = Array(fullQueue[1..<fullQueue.count])
    }
}
