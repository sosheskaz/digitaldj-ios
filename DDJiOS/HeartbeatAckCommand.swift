//
//  HeartbeatAck.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class HeartbeatAckCommand {
    static var command: String = "heartbeatAck"
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: HeartbeatAckCommand.command as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
