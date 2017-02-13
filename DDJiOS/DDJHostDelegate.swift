//
//  DDJHostDelegate.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/13/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

protocol DDJHostDelegate {
    func ddjHost(newUser: NewUserCommand)
    func ddjHost(removeUser: RemoveUserCommand)
    func ddjHost(updatePlaylist: [SPTTrack])
}
