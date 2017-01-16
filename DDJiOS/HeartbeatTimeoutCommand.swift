//
//  HeartbeatTimeoutCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
class HeartbeatTimeoutCommand: HostClientCommand {
    static var command: CommandType = .heartbeatTimeout
    static var destPort: CommandPort = .client
    
    required init?(from data: Data) {
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } catch {
            return nil
        }
    }
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: HeartbeatTimeoutCommand.command.rawValue as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
