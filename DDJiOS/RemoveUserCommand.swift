//
//  RemoveUserCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/1/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class RemoveUserCommand: ClientHostCommand {
    static var command: CommandType = .removeUser
    static let userIdLabel = "spotifyId"
    let spotifyId: String
    
    required init?(from data: Data) {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            
            self.spotifyId = dict[RemoveUserCommand.userIdLabel] as! String
        } catch {
            return nil
        }
    }
    
    init(userId: String) {
        self.spotifyId = userId
    }
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: RemoveUserCommand.command.rawValue as AnyObject,
             RemoveUserCommand.userIdLabel: self.spotifyId as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
