//
//  ClientCommandListener.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientCommandListener: CommandRunner {
    
    init() {
        super.init(.client)
        
        let actions: [CommandType: [(_: Command) -> Void]] = [
            .heartbeat: [sendHeartbeatAck],
            .updatePlaylist: [updatePlaylist],
            .heartbeatTimeout: [heartbeatTimeout]
        ]
        
        for (cmdType, closures) in actions {
            for closure in closures {
                self.subscribe(to: cmdType, callback: closure)
            }
        }
    }
    
    private func sendHeartbeatAck(heartbeat: Command) -> Void {
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
        let succeed = ack.execute(hb.address!)
        
        print("Sent ack: \(succeed)")
    }
    
    private func updatePlaylist(cmd: Command) -> Void {
        // TODO
    }
    
    private func heartbeatTimeout(cmd: Command) -> Void {
        // TODO
    }
}
