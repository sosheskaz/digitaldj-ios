//
//  HostCommandListener.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

private let server = ""

class HostCommandListener: CommandRunner {
    static let sharedHostListener = HostCommandListener()
    
    init() {
        super.init(.host)
        
        let actions: [CommandType: [(_: Command) -> Void]] = [
            .newUser: [handleNewUser],
            .heartbeatAck: [handleHeartbeatAck]
        ]
        
        for (cmdType, closures) in actions {
            for closure in closures {
                self.subscribe(to: cmdType, callback: closure)
            }
        }
        
        startSession()
    }
    
    deinit {
        endSession()
    }
    
    private func startSession() {
        
    }
    
    private func endSession() {
        
    }
    
    private func handleNewUser(cmd rawCmd: Command) -> Void {
        guard let cmd = rawCmd as? NewUserCommand else {
            return
        }
        
        let id = cmd.spotifyId
        
        func finishHandleNewUser(anyerror: Any?, anyuser: Any?) {
            guard anyerror == nil else {
                print("Failed to auth user.")
                print("Error: \(anyerror as! Error)")
                print("User:  \(anyuser as! SPTUser)")
                
                return
            }
            
            guard let user = anyuser as? SPTUser else {
                print("Something happened... user object returned is not SPTUser and an error was not thrown.")
                print("User:  \(anyuser)")
                
                return
            }
        }
    }
    
    private func handleHeartbeatAck(cmd: Command) {
        
    }
}
