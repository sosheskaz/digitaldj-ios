//
//  ServerEndSessionCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/27/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class ServerEndSessionCommand: ServerCommand {
    typealias T = Bool
    private var _subscribers: [(Result<Data>?) -> Void] = []
    private let sessionId: String

    init(sessionId: String) {
        self.sessionId = sessionId
    }

    class var command: ServerCommandType {
        return .endSession
    }
    class var method: Alamofire.HTTPMethod {
        return .post
    }
    var parameters: Alamofire.Parameters? {
        return ["sessionId": sessionId]
    }
    var subscribers: [(Result<Data>?) -> Void] {
        return _subscribers
    }
    func subscribe(_ listener: @escaping (Result<Data>?) -> Void) {
        _subscribers.append(listener)
    }
    
    static func getValue(from data: Data?) -> Bool {
        guard let rtrn = ServerNewSessionCommand.parseResponse(data) as? String else {
            return false
        }
        return Bool(rtrn) ?? false
    }
}
