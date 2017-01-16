//
//  HeartbeatCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class HeartbeatCommand: HostClientCommand {
    static var command: CommandType = .heartbeat
    
    var address: String? = nil
    
    init() {}
    
    required init?(from data: Data) {
        do {
            let _ = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } catch {
            return nil
        }
    }
    
    init?(from data: Data, address: String){
        do {
            let _ = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            self.address = address
        } catch {
            return nil
        }
    }
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: HeartbeatCommand.command.rawValue as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
