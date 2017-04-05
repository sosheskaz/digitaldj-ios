//
//  ServerViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 11/6/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AVFoundation
import AVKit

class ServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DDJHostDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    @IBOutlet var playlistTableView: UITableView? = nil
    @IBOutlet var serverNameLabel: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackName: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackAlbum: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackArtist: UILabel? = nil
    @IBOutlet var albumArt: UIImageView? = nil
    
    private let dq = DispatchQueue(label: "digitaldj_severViewController")
    
    let sptPlayer: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
    private let zc: ZeroconfServer = ZeroconfServer()
    private let host = DDJHost.shared
    private let DEFAULT_ZC_NAME: String = "iOS Digital DJ"
    
    private var zcName: String
    private var isStarted = false
    
    required init?(coder aDecoder: NSCoder) {
        self.zcName = DEFAULT_ZC_NAME
        super.init(coder: aDecoder)
        self.sptPlayer.delegate = self
    }
    
    func passZcNameData(_ name: String) {
        self.zcName = name
        start()
    }
    
    func start() {
        stop()
        isStarted = true
        zc.start(name: zcName)
        self.play()
    }
    
    func stop() {
        isStarted = false
        self.pause()
        zc.stop()
    }
    
    func ddjHost(newUser: NewUserCommand) {
        self.playlistTableView?.reloadData()
    }
    
    func ddjHost(updatePlaylist: [SPTTrack]) {
        self.playlistTableView?.reloadData()
    }
    
    func ddjHost(removeUser: RemoveUserCommand) {
        // TODO
    }
    
    // MARK: - AVPlayer
    
    
    // MARK: - ViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.serverNameLabel?.text = zcName
        
        super.viewDidAppear(animated)
        print(host.playlist.first!.playableUri.absoluteString)
        let track = host.playlist[0]
        
        self.sptPlayer.playbackDelegate = self
        
        self.sptPlayer.playSpotifyURI(track.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: nil)
        
        self.nowPlayingLabelTrackName?.text = track.name
        self.nowPlayingLabelTrackAlbum?.text = track.album.name
        self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        
        self.sptPlayer.queueSpotifyURI(host.playlist.first!.playableUri.absoluteString, callback: { error in
            print("NOT QUEUED! \(error)")
        })
        play()
        
        DispatchQueue.main.async {
            self.playlistTableView?.reloadData()
            let imageUrl = track.album.largestCover.imageURL
            let data = Alamofire.request(imageUrl!).responseData()
            let image = UIImage(data: data.data!)
            self.albumArt?.image = image
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - TableView
    
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
        self.playSong((self.host.playlistPeek()!.playableUri.absoluteString))
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        log.verbose("Spotify player did change position to \(position).")
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
        log.verbose("Spotify player did change metadata to \(metadata.currentTrack).")
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
        self.sptPlayer.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
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
        self.sptPlayer.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }

    // MARK: - Private functions
    
    private func pause() -> Void {
        self.sptPlayer.setIsPlaying(false, callback: nil)
    }
    
    private func play() {
        self.sptPlayer.setIsPlaying(true, callback: nil)
    }
    
    private func playSong(_ spotifyUri: String) {
        sptPlayer.playSpotifyURI(spotifyUri, startingWith: 0, startingWithPosition: 0, callback: nil)
        // metadata changed will be called, and it will play.
    }
    
    private func playSong(_ track: SPTTrack) {
        self.playSong(track.playableUri.absoluteString)
    }
}

protocol ServerViewControllerNameDelegate {
    var name: String {get}
}
