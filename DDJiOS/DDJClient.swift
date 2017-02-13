//
//  DDJClient.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/5/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class DDJClient: ClientCommandListenerDelegate {
    static let shared = DDJClient(heartbeatInterval: 45)
    
    private let heartbeatWait: UInt32
    
    private var ip: String?
    private var trackData: [String: SPTTrack] = [:]
    private var _playlist: [SPTTrack] = []
    
    private var clientListener: ClientCommandListener = ClientCommandListener.shared
    
    var delegate: DDJClientDelegate?
    
    private init(heartbeatInterval: UInt32) {
        self.heartbeatWait = heartbeatInterval
        
        self.heartbeatDaemon()
        clientListener.on()
        clientListener.delegate = self
    }
    
    var playlist: [SPTTrack] {
        get {
            return _playlist
        }
    }
    
    func connect(to ip: String) {
        clientListener.on()
        usleep(20000)
        self.ip = ip
        let didSend = self.sendNewUserCommand()
        print(didSend)
    }
    
    func disconnect() {
        clientListener.off()
        self.ip = nil
    }
    
    func sendNewUserCommand() -> Bool{
        guard let ip = self.ip else {
            return false
        }

        return NewUserCommand(userId: MySpt.shared.userId, topTracks: MySpt.shared.topTracks).execute(ip)
    }
    
    func sendHeartbeat() -> Bool {
        guard let ip = self.ip else {
            return false
        }
        return HeartbeatCommand().execute(ip)
    }
    
    func clientCommandListener(updatePlaylist: UpdatePlaylistCommand) {
        guard let cp = updatePlaylist.currentlyPlaying else {
            return
        }
        
        let masterList = [cp] + updatePlaylist.queue
        let toGet = masterList.filter { self.trackData[$0] == nil }
        
        guard let trackData = DDJSPTTools.SPTTracksFromIdsOrUris(toGet) else {
            return
        }
        for trackDatum in trackData {
            self.trackData[trackDatum.identifier] = trackDatum
        }
        self._playlist =  masterList.map { self.trackData[$0]! }
        
        delegate?.ddjClient(updatePlaylist: self.playlist)
    }
    
    func clientCommandListener(heartbeatTimeout: HeartbeatTimeoutCommand) {
        delegate?.ddjClientHeartbeatTimeout()
    }
    
    func clientCommandListener(heartbeat: HeartbeatCommand) {
        
    }
    
    private func heartbeatDaemon() {
        DispatchQueue.global().async {
            while(true) {
                guard self.ip != nil else {
                    sleep(self.heartbeatWait)
                    continue
                }
                _ = self.sendHeartbeat()
                sleep(self.heartbeatWait)
            }
        }
    }
}
