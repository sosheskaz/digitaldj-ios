//
// Created by Eric Miller on 1/25/17.
// Copyright (c) 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class ServerNewSessionCommand: ServerCommand {
    private var _subscribers: [(Data?) -> Void] = []
    var subscribers: [(Data?) -> Void] {
        return _subscribers
    }
    
    class var command: ServerCommandType {
        return .newSession
    }
    class var method: HTTPMethod {
        return .get
    }
    var parameters: Parameters? {
        return [:]
    }
    
    func subscribe(_ listener: @escaping (Data?) -> Void) {
        _subscribers.append(listener)
    }
    
    static func getSessionId(from data: Data) -> String? {
        guard var id = ServerNewSessionCommand.parseResponse(data) as? String else {
            return nil
        }
        id = id.trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
        
        return id
    }
}
