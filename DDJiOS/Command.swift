//
//  Command.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import SwiftSocket

let commandLabel: String = "command"
protocol Command {
    static var command: String {get}
    var json: Data? {get} // Failable
}

extension Command {
    func execute(_ address: String, port: Int32) {
        let client = TCPClient(address: address, port: port)
        switch client.connect(timeout: 10) {
        case .success:
            // Connection successful 🎉
            client.send(data: json!)
            break
        case .failure(let error):
            // 💩
            break
        }
    }
}
