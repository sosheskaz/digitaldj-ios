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
    static let shared = HostCommandListener()
    
    var delegate: HostCommandListenerDelegate?
    
    private init() {
        super.init(.host)
        
        let actions: [CommandType: [(_: Command) -> Void]] = [
            .newUser: [handleNewUser],
            .heartbeatAck: [handleHeartbeatAck],
            .removeUser: [handleRemoveUser]
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
        print("Got new user command. \n\tIP: \(cmd.source) \n\tSpotifyId: \(cmd.spotifyId) \n\tTopTracks: \(cmd.topTracks)")
        self.delegate?.hostCommandListener(newUser: cmd)
    }
    
    private func handleHeartbeatAck(cmd: Command) {
        guard let haCmd = cmd as? HeartbeatAckCommand else {
            return
        }
        self.delegate?.hostCommandListener(heartbeatAck: haCmd)
    }
    
    private func handleRemoveUser(cmd: Command) {
        guard let ruCmd = cmd as? RemoveUserCommand else {
            return
        }
        self.delegate?.hostCommandListener(removeUserCommand: ruCmd)
    }
}

protocol HostCommandListenerDelegate {
    func hostCommandListener(newUser: NewUserCommand)
    func hostCommandListener(heartbeatAck: HeartbeatAckCommand)
    func hostCommandListener(removeUserCommand: RemoveUserCommand)
}
