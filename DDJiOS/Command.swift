//
//  Command.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

let commandLabel: String = "command"
protocol Command {
    static var command: String {get}
    var json: Data? {get} // Failable
}
