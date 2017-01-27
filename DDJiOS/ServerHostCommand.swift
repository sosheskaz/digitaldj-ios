//
//  ServerHostCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/25/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

protocol ServerHostCommand: Command {
    
}

extension ServerHostCommand {
    static var destPort: CommandPort {
        get {
            return .host
        }
    }
}
