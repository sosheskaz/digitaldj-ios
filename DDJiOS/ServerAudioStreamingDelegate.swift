//
//  ServerAudioStreamingDelegate.swift
//  DDJiOS
//
//  Created by Eric Miller on 5/9/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ServerAudioStreamingDelegate: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    let host: DDJHost
    private let sptPlayer: SPTAudioStreamingController? = MySpt.shared.player
    private let dq = DispatchQueue(label: "host-audio-streaming-delegate")
    
    public init(host: DDJHost) {
        self.host = host
    }
    
    var isPlaying: Bool {
        get {
            return self.sptPlayer?.playbackState?.isPlaying ?? false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return host.playlist.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard host.playlist.count > indexPath.row - 1 else {
            return cell
        }
        cell.textLabel?.text = host.playlist[indexPath.row + 1].name
        return cell
    }
    
    // MARK: - Audio Streaming
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        var eventStr: String
        switch event {
        case SPPlaybackNotifyPlay:
            eventStr = ("SPPlaybackNotifyPlay fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyNext:
            eventStr = ("SPPlaybackNotifyNext fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyPrev:
            eventStr = ("SPPlaybackNotifyPrev fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyPause:
            eventStr = ("SPPlaybackNotifyPause fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyRepeatOn:
            eventStr = ("SPPlaybackNotifyRepeatOn fired. Rawvalue: \(event)")
            break
        case SPPlaybackEventAudioFlush:
            eventStr = ("SPPlaybackEventAudioFlush fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyRepeatOff:
            eventStr = ("SPPlaybackEventNotifyRepeatOff fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyShuffleOn:
            eventStr = ("SPPlaybackNotifyShuffleOn fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyShuffleOff:
            eventStr = ("SPPlaybackNotifyShuffleOff fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyBecameActive:
            eventStr = ("SPPlaybackNotifyBecameActive fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyTrackChanged:
            eventStr = ("SPPlaybackNotifyTrackChanged fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyBecameInactive:
            eventStr = ("SPPlaybackNotifyBecameInactive fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyContextChanged:
            eventStr = ("SPPlaybackNotifyContextChanged fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyLostPermission:
            eventStr = ("SPPlaybackNotifyLostPermission fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyTrackDelivered:
            eventStr = ("SPPlaybackNotifyTrackDelivered fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyMetadataChanged:
            eventStr = ("SPPlaybackNotifyMetadataChanged fired. Rawvalue: \(event)")
            break
        case SPPlaybackNotifyAudioDeliveryDone:
            eventStr = ("SPPlaybackNotifyAudioDeliveryDoneFired. Rawvalue: \(event)")
            break
        default:
            eventStr = "Unknown event fired. Rawvalue: \(event)"
            break
        }
        
        log.verbose(eventStr)
    }
    
    func playNext() {
        _ = self.host.playlistPop()
        self.playSong(spotifyUri: self.host.playlistPeek()!.playableUri.absoluteString)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        // log.verbose("Spotify player did change position to \(position).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        log.verbose("Spotify player did change playback status to \(isPlaying).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        log.verbose("Spotify player did seek to position \(position),")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
        log.verbose("Spotify player did change volume to \(volume.description).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
        log.verbose("Spotify player did change shuffle status to \(enabled).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) {
        log.verbose("Spotify player did change repeate mode to \(repeateMode).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        log.verbose("Spotify player did change metadata to \(String(describing: metadata.currentTrack)).")
        self.play()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        log.verbose("Spotify player did start playing \(trackUri).")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        log.verbose("Spotify player did stop playing \(trackUri).")
    }
    
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        log.verbose("Spotify player did skip to next track.")
        _ = self.host.playlistPop()
        self.sptPlayer?.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        log.error("An error occurred. If you're seeing this, contact Eric and/or add handling for it. \(error.localizedDescription)")
    }
    
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
        log.verbose("Spotify player did skip to previous track.")
    }
    
    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        log.verbose("Spotify player did become active playback device.")
    }
    
    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        log.verbose("Spotify player did become inactive playback device.")
        self.pause()
    }
    
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
        log.warning("Spotify player did lose permission for streaming!")
        self.pause()
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        log.verbose("Spotify player did pop its queue.")
        _ = self.host.playlistPop()
        self.sptPlayer?.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }
    
    func pause() -> Void {
        self.dq.async {
            self.sptPlayer?.setIsPlaying(false, callback: { error in
                log.error("Could not pause playback: \(error.debugDescription)")
            })
        }
    }
    
    func play()
    {
        self.dq.async {
            log.verbose(self.sptPlayer?.playbackState ?? "playback state is nil")
            self.sptPlayer?.setIsPlaying(true, callback: {error in
                log.error("Could not start playback: \(error.debugDescription)")
            })
        }
    }
    
    func playSong(spotifyUri: String) {
        self.dq.async {
            self.sptPlayer?.playSpotifyURI(spotifyUri, startingWith: 0, startingWithPosition: 0, callback: {error in
                log.error("Could not play song: \(error.debugDescription)")
            })
        }
        // metadata changed will be called, and it will play.
    }
    
    func playSong(_ track: SPTTrack) {
        self.dq.async {
            self.playSong(spotifyUri: track.playableUri.absoluteString)
        }
    }
    
    func skip() {
        _ = self.host.playlistPop()
        self.playSong(spotifyUri: self.host.playlistPeek()!.playableUri.absoluteString)
    }
}
