//
//  DDJHost.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/3/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class DDJHost {
    static var shared: DDJHost = DDJHost()
    let ttlSeconds = 60 * 15
    
    private var users: [String:UserEntry] = [:]
    private var playlist: [String] = []
    private var ttlDaemonQueue: DispatchQueue = DispatchQueue(label: "ddj.host.ttl.daemon", attributes: .concurrent)
    private var ttlQueueIsRunning = false
    private var ttlQueueShouldStop = false
    
    private var hostListener = HostCommandListener()
    
    private init() {
        hostListener.subscribe(to: .newUser, callback: handleNewUser)
        hostListener.subscribe(to: .removeUser, callback: handleRemoveUser)
    }
    
    func putUser(_ userId: String, tracks: [String], ipAddr: String) {
        users[userId] = UserEntry(userId: userId, ip: ipAddr, ttl: Date().addingTimeInterval(TimeInterval(ttlSeconds)), trackIds: tracks)
    }
    
    func ttlDaemon() {
        ttlDaemonQueue.async {
            if(self.ttlQueueIsRunning) {
                return
            }
            
            self.ttlQueueShouldStop = false
            self.ttlQueueIsRunning = true
            while(!self.ttlQueueShouldStop) {
                self.ttlCheck()
                sleep(20)
            }
            self.ttlQueueIsRunning = false
        }
    }
    
    func ttlCheck() {
        for (_, entry) in users {
            if(entry.ttl.seconds(from: Date()) <= 0) {
                users.removeValue(forKey: entry.userId)
                let timeoutCmd = HeartbeatTimeoutCommand()
                _ = timeoutCmd.execute(entry.ip)
            }
        }
    }
    
    private func handleNewUser(_ cmd: Command) {
        guard let nuCmd = cmd as? NewUserCommand else {
            return
        }
        guard let source = (nuCmd as Command).source else {
            return
        }
        
        putUser(nuCmd.spotifyId, tracks: nuCmd.topTracks, ipAddr: source)
    }
    
    private func handleRemoveUser(_ cmd: Command) {
        guard let ruCmd = cmd as? RemoveUserCommand else {
            return
        }
        guard ruCmd.source == users[ruCmd.spotifyId]?.ip && ruCmd.source != nil else {
            return
        }
        
        users.removeValue(forKey: ruCmd.source!)
    }
    
    struct UserEntry {
        let userId: String
        let ip: String
        var ttl: Date
        var trackIds: [String]
    }
}
