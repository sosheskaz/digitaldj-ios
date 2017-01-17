//
//  HostCommandListener.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

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
    }
    
    private func handleNewUser(cmd: Command) -> Void {
        
    }
    
    private func handleHeartbeatAck(cmd: Command) {
        
    }
}
