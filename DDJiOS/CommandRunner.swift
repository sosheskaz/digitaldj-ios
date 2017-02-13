//
//  CommandFactory.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/15/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import SwiftSocket

class CommandRunner {
    private let port: Int32
    private var callbacks: [CommandType: [(_: Command) -> Void]] = [:]
    
    private let servers: [TCPServer]
    
    private var isOn: Bool = false
    
    init(_ listeningPort: CommandPort) {
        let port = listeningPort.rawValue
        self.port = port
        
        let addresses = Set(getIFAddresses() + ["127.0.0.1"])
        
        self.servers = addresses.map {TCPServer(address: $0, port: port)}
        
        for type in allCommandTypes {
            self.callbacks[type] = []
        }
        on()
    }
    
    deinit {
        for server in servers {
            server.close()
        }
    }
    
    func on() {
        guard !isOn else {
            return
        }
        
        print("LISTENER ON")
        
        self.isOn = true
        for server in servers {
            DispatchQueue.global().async {
                switch server.listen() {
                case .success:
                    DispatchQueue.global().async {
                        while true {
                            if(!self.isOn) {
                                break
                            }
                            
                            if let client = server.accept() {
                                let bytes = client.read(1024 * 1024)
                                let data = Data(bytes: bytes!)
                                self.handleCommand(data, address: client.address)
                                client.close()
                            }
                        }
                    }
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
    
    func off() {
        if(isOn) {
            for server in servers {
                server.close()
            }
            self.isOn = false
        }
    }
    
    private func handleCommand(_ data: Data, address: String) {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            let cmdType: CommandType? = CommandType(rawValue: dict["command"] as! String)
            
            if(cmdType == nil) {
                return
            }
            
            var cmd: Command?
            switch cmdType! {
            case .heartbeat:
                cmd = HeartbeatCommand(from: data, address: address)
                break
            case .heartbeatAck:
                cmd = HeartbeatAckCommand(from: data, client: address)
                break
            case .heartbeatTimeout:
                cmd = HeartbeatTimeoutCommand(from: data)
                break
            case .newUser:
                cmd = NewUserCommand(from: data)
                break
            case .updatePlaylist:
                cmd = UpdatePlaylistCommand(from: data)
                break
            default:
                // 💩
                break
            }
            
            if(cmd == nil){
                return
            }
            
            cmd!.source = address
            
            for closure in callbacks[cmdType!]! {
                closure(cmd!)
            }
        } catch {
            
        }
    }
    
    func subscribe(to commandType: CommandType, callback: @escaping (Command) -> Void) {
        self.callbacks[commandType]?.append(callback)
    }
}
