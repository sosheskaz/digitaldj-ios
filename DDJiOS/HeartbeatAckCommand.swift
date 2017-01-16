//
//  HeartbeatAck.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

private let userIdLabel = "userId"

class HeartbeatAckCommand: ClientHostCommand {
    static var command: CommandType = .heartbeatAck
    static var destPort: CommandPort = .host
    
    var userId: String?
    
    required init?(from data: Data) {
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } catch {
            return nil
        }
    }
    
    init() {
    }
    
    convenience init?(from data: Data, client: String? = nil) {
        self.init(from: data)
        self.userId = userId!
    }
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: HeartbeatAckCommand.command.rawValue as AnyObject,
             userIdLabel: self.userId as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
