//
//  CommandFactory.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/15/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Socket

class CommandRunner {
    private let port: Int
    private var callbacks: [CommandType: [(_: Command) -> Void]] = [:]
    
    private let bufSize = 65536 // 2^16
    private var socket: Socket = EZSSL()!.socket
    private let handlerQueue = DispatchQueue(label: "command_runner_dq", attributes: .concurrent)
    
    private var isOn: Bool = false
    
    init(_ listeningPort: CommandPort) {
        let port = listeningPort.rawValue
        self.port = port
        
        for type in allCommandTypes {
            self.callbacks[type] = []
        }
        
        let didTurnOn = self.on()
        if !didTurnOn {
            log.warning("CommandRunner failed to turn on.")
        }
    }
    
    deinit {
        socket.close()
    }
    
    func on() -> Bool {
        var exitValue: Bool? = nil
        
        // Handles race conditions - make sure we're not already on.
        self.handlerQueue.sync {
            log.info("Attempting to turn CommandListener on. Is it already on? \(self.isOn)")
            guard !isOn else {
                log.warning("CommandListener is already on. Exiting early.")
                exitValue = true // Already on. Nothing to do.
                return
            }
            
            do {
                log.info("Trying to open socket for CommandListener.")
                self.socket = EZSSL()!.socket
                // socket.enableSSL()
                try socket.listen(on: self.port)
                log.info("Socket is \(socket.isListening ? "" : "not ")listening on \(socket.listeningPort).")
            } catch {
                log.warning("The port is already locked by something else. Exiting because there's not much else we can do for now.")
                exitValue = isOn // we may fail because the port is already locked by
                // another instance of this process. That's ok.
            }
        }
        
        if exitValue != nil {
            return exitValue!
        }
        
        self.isOn = true
        self.handlerQueue.async {
            repeat {
                if(!self.isOn) {
                    break
                }
                
                do {
                    log.info("Server waiting for connections on port \(self.port)")
                    let newSocket = try self.socket.acceptClientConnection()
                    log.info("Accepted a connection.")
                    
                    // Handle the request asynchronously so we can handle another right away.
                    self.handlerQueue.async {
                        log.info("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                        
                        var readData = Data(capacity: self.bufSize)
                        do {
                            _ = try newSocket.read(into: &readData)
                        } catch let error {
                            log.error("Failed to read from the socket!")
                            
                            if error is Socket.Error {
                                let serr = error as! Socket.Error
                                log.error("Socket.Error: \(serr.description)")
                            }
                            
                            return
                        }
                        
                        log.info("Handling a command from \(newSocket.remoteHostname)")
                        self.handleCommand(readData, address: newSocket.remoteHostname)
                    }
                } catch let error as Socket.Error {
                    if error.errorCode == -9994 {
                        log.warning("IMPORTANT! Most likely, the above error was caused by the application terminating. It should be nothing to worry about. But I've left the messages (following) in case something goes wrong we're not suppressing potentially helpful output.")
                        log.warning("Socket failed to open for listening on port \(self.port)")
                        log.warning(error.description)
                        break
                    }
                    log.error("Socket failed to open for listening on port \(self.port)")
                    log.error(error.description)
                } catch let error {
                    log.error("Socket failed to open for listening on port \(self.port)")
                    log.error("Error: \(error.localizedDescription)")
                    log.error("This error doesn't have a specific logging operation associated with it. Send Eric this log. eric.the.miller@icloud.com")
                    
                    guard let serr = error as? Socket.Error else {
                        break
                    }
                    
                    log.error(serr.description)
                }
            } while true
        }
        
        return true
    }
    
    func off() {
        handlerQueue.sync {
            if(isOn) {
                socket.close()
                self.isOn = false
            }
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
            case .removeUser:
                cmd = RemoveUserCommand(from: data)
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
