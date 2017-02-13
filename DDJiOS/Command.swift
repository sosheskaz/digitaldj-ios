//
//  Command.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import SwiftSocket

let commandLabel: String = "command"

// don't delete this
private struct associatedKeys {
    static var source: String?
}

protocol Command {
    static var command: CommandType {get}
    static var destPort: CommandPort {get}
    var json: Data? {get} // Failable
    
    var source: String? {get set}
    
    init?(from data: Data)
}

extension Command {
    func execute(_ address: String)  -> Bool {
        let client = TCPClient(address: address, port: Self.destPort.rawValue)
        print(address)
        var success = false
        
        switch client.connect(timeout: 10) {
        case .success:
            // Connection successful 🎉
            success = client.send(data: json!).isSuccess
            break
        case .failure(let error):
            // 💩
            print("COMMAND FAILED TO SEND \(error)")
            success = false
            break
        }
        
        return success
    }
    
    // "extensions may not contain stored properties" 🐇 🎩
    var source: String? {
        get {
            guard let value = objc_getAssociatedObject(self, &associatedKeys.source) as? String? else {
                return nil
            }
            return value
        }
        set(value) {
            objc_setAssociatedObject(self, &associatedKeys.source, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// When updating, also update allCommandTypes.
enum CommandType: String {
    case newUser = "newUser",
    updatePlaylist = "updatePlaylist",
    heartbeat = "heartbeat",
    heartbeatAck = "heartbeatAck",
    heartbeatTimeout = "heartbeatTimeout",
    removeUser = "removeUser"
}

let allCommandTypes: [CommandType] = [.newUser, .updatePlaylist, .heartbeat, .heartbeatAck, .heartbeatTimeout, .removeUser]

enum CommandPort: Int32 {
    case host = 52773, client = 52774, commandPort = 52775, server = 80
}
