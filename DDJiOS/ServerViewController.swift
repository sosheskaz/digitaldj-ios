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

class ServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DDJHostDelegate {
    @IBOutlet var playlistTableView: UITableView? = nil
    @IBOutlet var serverNameLabel: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackName: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackAlbum: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackArtist: UILabel? = nil
    @IBOutlet var albumArt: UIImageView? = nil
    @IBOutlet var playPauseButton: UIButton?
    @IBOutlet var skipButton: UIButton?
    
    private let dq = DispatchQueue(label: "digitaldj_severViewController")
    
    let sptPlayer: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
    private let zc: ZeroconfServer = ZeroconfServer.shared
    private let host = DDJHost.shared
    private let DEFAULT_ZC_NAME: String = "iOS Digital DJ"
    private let audioDelegate: ServerAudioStreamingDelegate = ServerAudioStreamingDelegate(host: DDJHost.shared)
    private let playIcon = #imageLiteral(resourceName: "Circled Play-100")
    private let pauseIcon = #imageLiteral(resourceName: "Circled Pause-100")
    
    private var zcName: String
    private var isStarted = false
    
    required init?(coder aDecoder: NSCoder) {
        self.zcName = DEFAULT_ZC_NAME
        super.init(coder: aDecoder)
    }
    
    func passZcNameData(_ name: String) {
        self.zcName = name
    }
    
    func start() {
        self.dq.async {
            log.verbose("Server starting.")
            self.isStarted = true
            self.zc.start(name: self.zcName)
            self.audioDelegate.play()
            log.verbose("Started")
        }
    }
    
    func stop() {
        self.isStarted = false
        if self.sptPlayer.playbackState.isPlaying{
            self.audioDelegate.pause()
        }
        self.zc.stop()
    }
    
    func ddjHost(newUser: NewUserCommand) {
        DispatchQueue.main.async {
            self.playlistTableView?.reloadData()
        }
    }
    
    func ddjHost(updatePlaylist: [SPTTrack]) {
        DispatchQueue.main.async {
            self.playlistTableView?.reloadData()
        }
    }
    
    func ddjHost(removeUser: RemoveUserCommand) {
        // TODO
    }
    
    @IBAction func playPauseButtonClicked() {
        if self.audioDelegate.isPlaying {
            self.playPauseButton?.setImage(self.playIcon, for: .normal)
            self.audioDelegate.pause()
        } else {
            self.playPauseButton?.setImage(self.pauseIcon, for: .normal)
            self.audioDelegate.play()
        }
    }
    
    @IBAction func skipButtonClicked() {
        self.audioDelegate.skip()
        let track = self.host.playlistPeek()
        self.albumArt?.image = track?.albumArt
        self.nowPlayingLabelTrackName?.text = track?.name
        self.nowPlayingLabelTrackAlbum?.text = track?.album.name
        self.nowPlayingLabelTrackArtist?.text = track?.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        DispatchQueue.main.async {
            self.playlistTableView?.reloadData()
            // self.playlistTableView?.beginUpdates()
        }
    }
    
    // MARK: - ViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose("Server view will appear.")
        self.start()
        DispatchQueue.main.async {
            guard let album = self.albumArt else {
                return
            }
            let x = album.frame.minX
            let y = album.frame.minY
            let width = album.frame.maxX - x
            let height = width
            album.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // self.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.serverNameLabel?.text = zcName
        log.info("Playing URI \(host.playlist.first!.playableUri.absoluteString)")
        let track = host.playlist[0]
        
        self.sptPlayer.playbackDelegate = self.audioDelegate
        
        self.sptPlayer.playSpotifyURI(track.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { error in
            log.error("Failed to start playback: \(error.debugDescription)")
        })
        
        self.nowPlayingLabelTrackName?.text = track.name
        self.nowPlayingLabelTrackAlbum?.text = track.album.name
        self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        
        self.sptPlayer.queueSpotifyURI(host.playlist.first!.playableUri.absoluteString, callback: { error in
            log.error("NOT QUEUED! \(String(describing: error))")
        })
        self.audioDelegate.play()
        
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
        log.verbose("TableView row count updated: \(host.playlist.count - 1)")
        return host.playlist.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nullableCell = self.playlistTableView?.dequeueReusableCell(withIdentifier: "server-playlist-cell")
        let cell = nullableCell ?? UITableViewCell()
        guard host.playlist.count > indexPath.row - 1 else {
            log.warning("TableView returning empty cell.")
            return cell
        }
        log.verbose("Logging full cell with text: \(host.playlist[indexPath.row + 1].name)")
        cell.textLabel?.text = host.playlist[indexPath.row + 1].name
        return cell
    }
}

protocol ServerViewControllerNameDelegate {
    var name: String {get}
}
