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
    static var command: CommandType = .updatePlaylist
    
    var currentlyPlaying: String
    var queue: Array<String>
    
    required init?(from data: Data) {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            
            self.currentlyPlaying = dict[currentlyPlayingLabel] as! String
            self.queue = dict[queueLabel] as! [String]
        } catch {
            return nil
        }
    }
    
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: UpdatePlaylistCommand.command.rawValue as AnyObject,
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
