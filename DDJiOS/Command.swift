//
//  Command.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import BlueSocket

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
        log.info("Attempting to send command \(String(describing: Self.command)) to \(address):\(Self.destPort.rawValue)")
        let client = EZSSL()!.socket
        
        log.info("Sending command \(String(describing: Self.command)) to real address \(client.remoteHostname):\(client.remotePort)")
        
        // We need to guarantee cleanup of resources when this function exits.
        // This is cleaner than individually handling each case, and allows early exits
        // in the logic. Also consolidates error logging logic.
        let wasSuccessful: Bool
        do {
            wasSuccessful = try failableExecute(client: client, address: address)
        } catch let error as Socket.Error {
            wasSuccessful = false
            
            log.error(error.description)
        } catch let error {
            wasSuccessful = false
            
            log.error(error.localizedDescription)
            log.error("This error doesn't have a specific logging operation associated with it. Send Eric this log. eric.the.miller@icloud.com")
        }
        
        client.close()
        return wasSuccessful
    }
    
    private func failableExecute(client: Socket, address: String) throws -> Bool {
        // Open the connection
        do {
            try client.connect(to: address, port: Int32(Self.destPort.rawValue))
        } catch let error {
            log.error("Failed to connect to \(address):\(Self.destPort.rawValue)")
            throw error
        }
        
        // Write our data
        do {
            try client.write(from: json!)
        } catch let error {
            log.error("Failed to write data to \(address):\(Self.destPort.rawValue)")
            throw error
        }
        
        return true
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

enum CommandPort: Int {
    case host = 55789, client = 55788, commandPort = 0 /*52775*/, server = 80
}
