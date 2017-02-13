//
//  DDJClientDelegate.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/13/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

protocol DDJClientDelegate {
    func ddjClient(updatePlaylist: [SPTTrack])
    func ddjClientHeartbeatTimeout()
}
