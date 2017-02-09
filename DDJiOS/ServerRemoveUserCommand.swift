//
//  ServerRemoveUserCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/8/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class ServerRemoveUserCommand: ServerCommand {
    typealias T = Bool
    private var _subscribers: [(Result<Data>?) -> Void] = []
    private var userId: String
    private var sessionId: String
    class var command: ServerCommandType {
        return .removeUser
    }
    
    class var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters? {
        return ["sessionId": self.sessionId,
                "userId": self.userId]
    }
    
    var subscribers: [(Result<Data>?) -> Void] {
        return _subscribers
    }
    
    init(_ userId: String, sessionId: String) {
        self.userId = userId
        self.sessionId = sessionId
    }
    
    func subscribe(_ listener: @escaping (Result<Data>?) -> Void) {
        self._subscribers.append(listener)
    }
    
    static func getValue(from data: Data?) -> Bool {
        guard let rtrn = ServerNewSessionCommand.parseResponse(data) as? String else {
            return false
        }
        return Bool(rtrn) ?? false
    }
}
