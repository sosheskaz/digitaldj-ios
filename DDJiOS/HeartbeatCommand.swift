//
//  HeartbeatCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class HeartbeatCommand: HostClientCommand {
    static var command: String = "heartbeat"
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: HeartbeatCommand.command as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
