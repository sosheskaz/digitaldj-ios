//
//  ClientHostCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

protocol ClientHostCommand: Command {
    
}

extension ClientHostCommand {
    static var destPort: CommandPort {
        get {
            print("DESTPORT: \(CommandPort.host.rawValue)")
            return .host
        }
    }
}
