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
    private var _subscribers: [(Data?) -> Void] = []
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
    var subscribers: [(Data?) -> Void] {
        return _subscribers
    }
    func subscribe(_ listener: @escaping (Data?) -> Void) {
        _subscribers.append(listener)
    }
    
    
}
