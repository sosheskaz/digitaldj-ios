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
    private var _subscribers: [(Data?) -> Void] = []
    private var sessionId: String
    
    class var command: ServerCommandType {
        return .getPlaylist
    }
    
    class var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return ["sessionId": self.sessionId]
    }
    
    var subscribers: [(Data?) -> Void] {
        return _subscribers
    }
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
    
    func subscribe(_ listener: @escaping (Data?) -> Void) {
        _subscribers.append(listener)
    }
}
