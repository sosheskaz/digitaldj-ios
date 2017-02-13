//
//  DDJHost.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/3/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class DDJHost {
    static var shared: DDJHost = DDJHost(timeoutSeconds: 60 * 15, checkSeconds: 60)
    
    private let numToHaveInQueue: UInt = 10
    
    private var ttlSeconds: Int
    private var checkSeconds: UInt32
    
    private var users: [String: UserEntry] = [:]
    private var ips: [String: UserEntry] = [:]
    private var _playlist: [SPTTrack] = []
    private var ttlDaemonQueue: DispatchQueue = DispatchQueue(label: "ddj.host.ttl.daemon", attributes: .concurrent)
    private var ttlQueueIsRunning = false
    private var ttlQueueShouldStop = false
    private var subscribers: [CommandType: [(Command) -> Void]] = [:]
    private var sessionId: String?
    private var toDoOnPlaylistUpdate: [(DDJHost) -> Void] = []
    
    private var hostListener = HostCommandListener()
    
    private init(timeoutSeconds: Int, checkSeconds: UInt32) {
        self.checkSeconds = checkSeconds
        self.ttlSeconds = timeoutSeconds
        
        hostListener.subscribe(to: .newUser, callback: handleNewUser)
        hostListener.subscribe(to: .removeUser, callback: handleRemoveUser)
        hostListener.subscribe(to: .heartbeat, callback: handleHeartbeat)
        hostListener.on()
        
        let nsCmd = ServerNewSessionCommand()
        self.sessionId = ServerNewSessionCommand.getValue(from: nsCmd.executeSync().data)
        
        ttlDaemon()
        
        self.putUser(MySpt.shared.userId, tracks: MySpt.shared.topTracks, ipAddr: "127.0.0.1")
    }
    
    var topTracks: [String] {
        get {
            var arr: [String] = []
            
            for (_, value) in users {
                arr += value.trackIds
            }
            
            return arr
        }
    }
    
    var playlist: [SPTTrack] {
        get {
            return _playlist
        }
    }
    
    func subscribe(to ct: CommandType, _ callback: @escaping (Command) -> Void) {
        if(self.subscribers[ct] == nil) {
            self.subscribers[ct] = []
        }
        self.subscribers[ct]?.append(callback)
    }
    
    func clearSubscribers() {
        self.subscribers = [:]
    }
    
    func putUser(_ userId: String, tracks: [String], ipAddr: String) {
        let numPrevUsers = users.count
        
        let nuCmd = ServerNewUserCommand(tracks: tracks, sessionId: self.sessionId!)
        let uid = ServerNewUserCommand.getValue(from: nuCmd.executeSync().data)
        
        let entry = UserEntry(userId: userId, ip: ipAddr, ttl: Date().addingTimeInterval(TimeInterval(ttlSeconds)), trackIds: tracks, serverId: uid!)
        users[userId] = entry
        ips[ipAddr] = entry
        
        let songsToReplace = min(Int(numPrevUsers > 1 ? (1 / sqrt(Double(numPrevUsers))) * 10 : 15), self._playlist.count)
        self._playlist.removeLast(songsToReplace)
        let songsToGet = 15 - self._playlist.count
        let gpCmd = ServerGetPlaylistCommand(sessionId: self.sessionId!, numTracksToGet: UInt(songsToGet))
        let result = gpCmd.executeSync()
        let items = ServerGetPlaylistCommand.getValue(from: result.data)
        
        guard let tracks = DDJSPTTools.SPTTracksFromIdsOrUris(items) else {
            //TODO: Notify user of error
            return
        }
        self._playlist += tracks
        
        self.toDoOnPlaylistUpdate.forEach { closure in
            DispatchQueue.global().async {
                closure(self)
            }
        }
    }
    
    func onPlaylistUpdate(do closure: @escaping (DDJHost) -> Void) {
        self.toDoOnPlaylistUpdate.append(closure)
    }
    
    func ttlDaemon() {
        if(self.ttlQueueIsRunning) {
            return
        }
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
        
        guard let subscribers = self.subscribers[.newUser] else {
            return
        }
        
        for subscriber in subscribers {
            subscriber(cmd)
        }
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
        
        guard let subscribers = self.subscribers[.newUser] else {
            return
        }
        
        for subscriber in subscribers {
            subscriber(cmd)
        }
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
        
        guard let subscribers = self.subscribers[.newUser] else {
            return
        }
        
        for subscriber in subscribers {
            subscriber(cmd)
        }
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
        let serverId: String
        
        init(userId: String, ip: String, ttl: Date, trackIds: [String], serverId: String) {
            self.userId = userId
            self.ip = ip
            self.ttl = ttl
            self.trackIds = trackIds
            self.serverId = serverId
        }
    }
}
