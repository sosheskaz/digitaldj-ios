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
    
    private init(heartbeatInterval: UInt32) {
        self.heartbeatWait = heartbeatInterval
        
        listener = ClientCommandListener()
        listener.subscribe(to: .heartbeatAck, callback: handleHeartbeatAck)
        listener.subscribe(to: .heartbeatTimeout, callback: handleHeartbeatTimeout)
        listener.subscribe(to: .updatePlaylist, callback: handleUpdatePlaylist)
        self.heartbeatDaemon()
    }
    
    func connect(to ip: String) {
        listener.on()
        usleep(20000)
        self.ip = ip
        _ = self.sendNewUserCommand()
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
        
        // todo
    }
    
    private func handleUpdatePlaylist(cmd: Command) {
        guard let upCmd = cmd as? UpdatePlaylistCommand else {
            return
        }
        guard upCmd.source == ip else {
            return
        }
        
        let toGet = upCmd.queue.filter({ trackId in
            return self.trackData[trackId] == nil
        })
        
        do {
            let req = try SPTTrack.createRequest(forTracks: toGet, withAccessToken: MySpt.shared.token, market: "US")
            Alamofire.request(req).validate().responseJSON(completionHandler: { response in
                do {
                    let trackData = try SPTTrack.tracks(from: response.data!, with: response.response)
                    for trackDatum in trackData {
                        guard let track = trackDatum as? SPTTrack else {
                            return
                        }
                        self.trackData[track.identifier] = track
                    }
                    
                    self._playlist = upCmd.queue.map({ trackId in
                        return self.trackData[trackId]!
                    })
                    
                    for (key, value) in self.trackData {
                        if(!self._playlist.contains(value)) {
                            self.trackData.removeValue(forKey: key)
                        }
                    }
                } catch {
                    return
                }
            }).resume()
        } catch {
            return
        }
    }
}
