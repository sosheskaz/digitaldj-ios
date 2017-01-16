//
//  NewUserCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

private let userIdLabel = "spotifyId"
private let topTracksLabel = "topTracks"

class NewUserCommand: ClientHostCommand {
    static var command: CommandType = .newUser
    
    var spotifyId: String = ""
    var topTracks: [String] = []
    
    required init?(from data: Data) {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            
            self.spotifyId = dict[userIdLabel] as! String
            self.topTracks = dict[topTracksLabel] as! [String]
        } catch {
            return nil
        }
    }
    
    init(userId: String, topTracks: [String]) {
        self.spotifyId = userId
        self.topTracks = topTracks
    }
    
    var json: Data? {
        let dict: Dictionary<String, AnyObject> =
            [commandLabel: NewUserCommand.command.rawValue as AnyObject,
             userIdLabel: self.spotifyId as AnyObject,
             topTracksLabel: self.topTracks as AnyObject]
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("An error occurred while serializing UpdatePlaylistCommand to JSON.")
            return nil
        }
    }
}
