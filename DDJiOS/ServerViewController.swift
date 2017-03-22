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

class ServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DDJHostDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    @IBOutlet var playlistTableView: UITableView? = nil
    @IBOutlet var serverNameLabel: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackName: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackAlbum: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackArtist: UILabel? = nil
    @IBOutlet var albumArt: UIImageView? = nil
    
    let player: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    let auth = SPTAuth.defaultInstance()
    
    private let zc: ZeroconfServer = ZeroconfServer()
    private let host = DDJHost.shared
    private let DEFAULT_ZC_NAME: String = "iOS Digital DJ"
    
    private var zcName: String
    private var isStarted = false
    
    required init?(coder aDecoder: NSCoder) {
        self.zcName = DEFAULT_ZC_NAME
        super.init(coder: aDecoder)
        self.player.delegate = self
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
        
    }
    
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
        
        self.player.playbackDelegate = self
        
        self.player.playSpotifyURI(track.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: nil)
        
        self.nowPlayingLabelTrackName?.text = track.name
        self.nowPlayingLabelTrackAlbum?.text = track.album.name
        self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        
        self.player.queueSpotifyURI(host.playlist.first!.playableUri.absoluteString, callback: { error in
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
        print("Did event \(event)")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("Did change playback")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        print("did change metadata")
        print(metadata.currentTrack)
        print(metadata.description)
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("Did start")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Did stop")
    }

    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        print("Did skip")
        _ = self.host.playlistPop()
        self.player.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }

    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        self.pause()
    }

    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
        self.pause()
    }

    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        print("POPPING")
        _ = self.host.playlistPop()
        self.player.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }

    // MARK: - Private functions
    
    private func pause() -> Void {
        self.player.setIsPlaying(false, callback: nil)
    }
    
    private func play() {
        self.player.setIsPlaying(true, callback: nil)
    }
    
    private func playSong(_ spotifyUri: String) {
        player.playSpotifyURI(spotifyUri, startingWith: 0, startingWithPosition: 0, callback: nil)
    }
}

protocol ServerViewControllerNameDelegate {
    var name: String {get}
}
