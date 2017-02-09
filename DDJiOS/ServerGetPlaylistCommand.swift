//
//  ServerGetPlaylistCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/6/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class ServerGetPlaylistCommand: ServerCommand {
    typealias T = [String]
    private var _subscribers: [(Result<Data>?) -> Void] = []
    private var sessionId: String
    
    class var command: ServerCommandType {
        return .getPlaylist
    }
    
    class var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return ["sessionId": self.sessionId,
                "playlistLength": 25]
    }
    
    var subscribers: [(Result<Data>?) -> Void] {
        return _subscribers
    }
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
    
    func subscribe(_ listener: @escaping (Result<Data>?) -> Void) {
        _subscribers.append(listener)
    }
    
    static func getValue(from data: Data?) -> Array<String> {
        return ServerGetPlaylistCommand.parseResponse(data) as? [String] ?? []
    }
}
