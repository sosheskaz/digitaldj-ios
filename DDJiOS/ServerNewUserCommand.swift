//
//  ServerAddUserComand.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/6/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class ServerNewUserCommand: ServerCommand {
    private var _subscribers: [(Data?) -> Void] = []
    private var userId: String
    private var topTracks: [String]
    private var sessionId: String
    
    class var command: ServerCommandType {
        return .newUser
    }
    
    class var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters? {
        return ["sessionId": self.sessionId,
                "songIds": self.topTracks]
    }
    
    var subscribers: [(Data?) -> Void] {
        return _subscribers
    }
    
    init(_ userId: String, tracks: [String], sessionId: String) {
        self.userId = userId
        self.topTracks = tracks
        self.sessionId = sessionId
    }
    
    func subscribe(_ listener: @escaping (Data?) -> Void) {
        self._subscribers.append(listener)
    }
    
    static func getUserId(from data: Data) -> String? {
        guard var id = ServerNewUserCommand.parseResponse(data) as? String else {
            return nil
        }
        
        id = id.trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
        return id
    }
}
