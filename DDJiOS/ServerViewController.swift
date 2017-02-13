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

class ServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DDJHostDelegate, SPTAudioStreamingPlaybackDelegate {
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.serverNameLabel?.text = zcName
        
        super.viewDidAppear(animated)
        print(host.playlist.first!.playableUri.absoluteString)
        let track = host.playlistPop()
        
        self.player.playbackDelegate = self
        
        self.player.playSpotifyURI(track.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: nil)
        
        self.nowPlayingLabelTrackName?.text = track.name
        self.nowPlayingLabelTrackAlbum?.text = track.album.name
        self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        
        self.player.queueSpotifyURI(host.playlist.first!.playableUri.absoluteString, callback: { error in
            print("QUEUED! \(error)")
        })
        self.player.setIsPlaying(true, callback: nil)
        
        DispatchQueue.global().async {
            let imageUrl = track.album.largestCover.imageURL
            let data = Alamofire.request(imageUrl!).responseData()
            let image = UIImage(data: data.data!)
            self.albumArt?.image = image
        }
        
        self.playlistTableView?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func play(spotifyUri: String) {
        player.playSpotifyURI(spotifyUri, startingWith: 0, startingWithPosition: 0, callback: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.zcName = DEFAULT_ZC_NAME
        super.init(coder: aDecoder)
    }
    
    func passZcNameData(name: String) {
        self.zcName = name
        start()
    }
    
    func start() {
        stop()
        isStarted = true
        zc.start(name: zcName)
    }
    
    func stop() {
        isStarted = false
        zc.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return host.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = host.playlist[indexPath.row].name
        return cell
    }
    
    func ddjHost(newUser: NewUserCommand) {
        
    }
    
    func ddjHost(updatePlaylist: [SPTTrack]) {
        
    }
    
    func ddjHost(removeUser: RemoveUserCommand) {
        
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
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
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
    }

    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        _ = self.host.playlistPop()
        self.player.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }

    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
    }

    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        _ = self.host.playlistPop()
        self.player.queueSpotifyURI(self.host.playlist.first!.playableUri.absoluteString, callback: nil)
    }

}

protocol ServerViewControllerNameDelegate {
    var name: String {get}
}
