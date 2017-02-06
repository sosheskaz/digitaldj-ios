//
//  DDJHost.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/3/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class DDJHost {
    static var shared: DDJHost = DDJHost(timeoutSeconds: 60 * 15, checkSeconds: 60)
    
    private var ttlSeconds: Int
    private var checkSeconds: UInt32
    
    private var users: [String: UserEntry] = [:]
    private var ips: [String: UserEntry] = [:]
    private var playlist: [String] = []
    private var ttlDaemonQueue: DispatchQueue = DispatchQueue(label: "ddj.host.ttl.daemon", attributes: .concurrent)
    private var ttlQueueIsRunning = false
    private var ttlQueueShouldStop = false
    
    private var hostListener = HostCommandListener()
    
    private init(timeoutSeconds: Int, checkSeconds: UInt32) {
        self.checkSeconds = checkSeconds
        self.ttlSeconds = timeoutSeconds
        
        hostListener.subscribe(to: .newUser, callback: handleNewUser)
        hostListener.subscribe(to: .removeUser, callback: handleRemoveUser)
        hostListener.subscribe(to: .heartbeat, callback: handleHeartbeat)
        ttlDaemon()
    }
    
    var tracks: [String] {
        get {
            var arr: [String] = []
            
            for (_, value) in users {
                arr += value.trackIds
            }
            
            return arr
        }
    }
    
    func putUser(_ userId: String, tracks: [String], ipAddr: String) {
        let entry = UserEntry(userId: userId, ip: ipAddr, ttl: Date().addingTimeInterval(TimeInterval(ttlSeconds)), trackIds: tracks)
        users[userId] = entry
        ips[ipAddr] = entry
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
                sleep(self.checkSeconds)
            }
            self.ttlQueueIsRunning = false
        }
    }
    
    func ttlCheck() {
        for (_, entry) in users {
            if(entry.ttl.seconds(from: Date()) <= 0) {
                ips.removeValue(forKey: entry.ip)
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
        guard let source = cmd.source else {
            return
        }
        guard source == users[ruCmd.spotifyId]?.ip else {
            return
        }
        guard let entry = ips[source] else {
            return
        }
        
        users.removeValue(forKey: entry.userId)
        ips.removeValue(forKey: source)
    }
    
    private func handleHeartbeat(_ cmd: Command) {
        guard let hbCmd = cmd as? HeartbeatCommand else {
            return
        }
        guard let source = hbCmd.source else {
            return
        }
        guard let entry = ips[source] else {
            return
        }
        
        self.putUser(entry.userId, tracks: entry.trackIds, ipAddr: entry.ip)
        
        let ackCmd = HeartbeatAckCommand()
        _ = ackCmd.execute(source)
    }
    
    static func sharedTestable(timeoutSeconds: Int, checkSeconds: UInt32) -> DDJHost{
        let host = DDJHost(timeoutSeconds: timeoutSeconds, checkSeconds: checkSeconds)
        host.ttlSeconds = timeoutSeconds
        host.checkSeconds = checkSeconds
        return host
    }
    
    class UserEntry {
        let userId: String
        let ip: String
        var ttl: Date
        var trackIds: [String]
        
        init(userId: String, ip: String, ttl: Date, trackIds: [String]) {
            self.userId = userId
            self.ip = ip
            self.ttl = ttl
            self.trackIds = trackIds
        }
    }
}
