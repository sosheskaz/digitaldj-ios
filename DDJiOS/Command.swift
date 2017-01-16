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
protocol Command {
    static var command: CommandType {get}
    static var destPort: CommandPort {get}
    var json: Data? {get} // Failable
    
    
    init?(from data: Data)
}

extension Command {
    var destPort: CommandPort {
        get {
            return CommandPort.commandPort
        }
    }
    
    func execute(_ address: String)  -> Bool {
        let client = TCPClient(address: address, port: Self.destPort.rawValue)
        
        var success = false
        
        switch client.connect(timeout: 10) {
        case .success:
            // Connection successful 🎉
            success = client.send(data: json!).isSuccess
            break
        case .failure(let error):
            // 💩
            print(error)
            success = false
            break
        }
        
        return success
    }
}

// When updating, also update allCommandTypes.
enum CommandType: String {
    case newUser = "newUser",
    updatePlaylist = "updatePlaylist",
    heartbeat = "heartbeat",
    heartbeatAck = "heartbeatAcq",
    heartbeatTimeout = "heartbeatTimeout"
}

let allCommandTypes: [CommandType] = [.newUser, .updatePlaylist, .heartbeat, .heartbeatAck, .heartbeatTimeout]
