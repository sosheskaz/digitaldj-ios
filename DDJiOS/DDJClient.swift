//
//  DDJClient.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/5/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class DDJClient {
    static let shared = DDJClient(heartbeatInterval: 45)
    
    private let heartbeatWait: UInt32
    
    private var ip: String?
    private var listener: ClientCommandListener
    private var trackData: [String: SPTTrack] = [:]
    private var _playlist: [SPTTrack] = []
    
    private var clientListener: ClientCommandListener = ClientCommandListener()
    
    var delegate: DDJClientDelegate?
    
    private init(heartbeatInterval: UInt32) {
        self.heartbeatWait = heartbeatInterval
        
        listener = ClientCommandListener()
        listener.subscribe(to: .heartbeatAck, callback: handleHeartbeatAck)
        listener.subscribe(to: .heartbeatTimeout, callback: handleHeartbeatTimeout)
        listener.subscribe(to: .updatePlaylist, callback: handleUpdatePlaylist)
        self.heartbeatDaemon()
        clientListener.subscribe(to: .updatePlaylist, callback: handleUpdatePlaylist)
        clientListener.on()
    }
    
    var playlist: [SPTTrack] {
        get {
            return _playlist
        }
    }
    
    func connect(to ip: String) {
        listener.on()
        usleep(20000)
        self.ip = ip
        let didSend = self.sendNewUserCommand()
        print(didSend)
    }
    
    func disconnect() {
        listener.off()
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
    
    private func handleHeartbeatAck(_ cmd: Command) {
        guard let haCmd = cmd as? HeartbeatAckCommand else {
            return
        }
        guard haCmd.source == ip else {
            return
        }
        print("Heartbeat ack received.")
        
        // do nothing... for now
    }
    
    private func handleHeartbeatTimeout(_ cmd: Command) {
        guard let htCmd = cmd as? HeartbeatTimeoutCommand else {
            return
        }
        guard htCmd.source == ip else {
            return
        }
        
        delegate?.ddjClientHeartbeatTimeout()
    }
    
    private func handleUpdatePlaylist(cmd: Command) {
        print("UPDATE PLAYLIST")
        guard let upCmd = cmd as? UpdatePlaylistCommand else {
            return
        }
        guard upCmd.source == ip else {
            return
        }
        
        let toGet = upCmd.queue.filter { self.trackData[$0] == nil }
        
        guard let trackData = DDJSPTTools.SPTTracksFromIdsOrUris(toGet) else {
            return
        }
        for trackDatum in trackData {
            self.trackData[trackDatum.identifier] = trackDatum
        }
        self._playlist = upCmd.queue.map { self.trackData[$0]! }
        
        DispatchQueue.global().async {
            for (key, value) in self.trackData {
                if(!self._playlist.contains(value)) {
                    self.trackData.removeValue(forKey: key)
                }
            }
        }
        
        delegate?.ddjClient(updatePlaylist: self.playlist)
    }
}
