//
//  ClientCommandListener.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientCommandListener: CommandRunner {
    static let shared = ClientCommandListener()
    
    var delegate: ClientCommandListenerDelegate?
    
    private init() {
        super.init(.client)
        
        let actions: [CommandType: [(_: Command) -> Void]] = [
            .heartbeat: [handleHeartbeat],
            .updatePlaylist: [updatePlaylist],
            .heartbeatTimeout: [heartbeatTimeout]
        ]
        
        for (cmdType, closures) in actions {
            for closure in closures {
                self.subscribe(to: cmdType, callback: closure)
            }
        }
    }
    
    private func handleHeartbeat(heartbeat: Command) -> Void {
        guard heartbeat is HeartbeatCommand else {
            print("not a heartbeat command.")
            return
        }
        guard (heartbeat as? HeartbeatCommand)?.address != nil else {
            print("Heartbeat didn't have a return address.")
            return
        }
        
        let hb = heartbeat as! HeartbeatCommand
        let ack = HeartbeatAckCommand()
        _ = ack.execute(hb.address!)
        
        delegate?.clientCommandListener(heartbeat: hb)
    }
    
    private func updatePlaylist(cmd: Command) -> Void {
        guard let upCmd = cmd as? UpdatePlaylistCommand else {
            return
        }
        delegate?.clientCommandListener(updatePlaylist: upCmd)
    }
    
    private func heartbeatTimeout(cmd: Command) -> Void {
        guard let htCmd = cmd as? HeartbeatTimeoutCommand else {
            return
        }
        delegate?.clientCommandListener(heartbeatTimeout: htCmd)
    }
}

protocol ClientCommandListenerDelegate {
    func clientCommandListener(heartbeat: HeartbeatCommand)
    func clientCommandListener(updatePlaylist: UpdatePlaylistCommand)
    func clientCommandListener(heartbeatTimeout: HeartbeatTimeoutCommand)
}
