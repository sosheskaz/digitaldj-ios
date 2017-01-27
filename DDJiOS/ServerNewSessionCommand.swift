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
    
    static func parseResponse(_ responseData: Data?) -> String? {
        print("parseResponse")
        guard let data = responseData else {
            print("nil")
            return nil
        }
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
