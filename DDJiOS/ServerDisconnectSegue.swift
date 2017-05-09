//
//  ServerDisconnectSegue.swift
//  DDJiOS
//
//  Created by Eric Miller on 5/4/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ServerDisconnectSegue: UIStoryboardSegue {
    override func perform() {
        super.perform()
        MySpt.shared.player?.setIsPlaying(false, callback: nil)
        ZeroconfServer.shared.stop()
    }
}
