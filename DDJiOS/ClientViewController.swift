//
//  ClientViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientViewController: UIViewController, DDJClientDelegate {
    @IBOutlet var playlistTableView: UITableView? = nil
    @IBOutlet var serverNameLabel: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackName: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackAlbum: UILabel? = nil
    @IBOutlet var nowPlayingLabelTrackArtist: UILabel? = nil
    @IBOutlet var albumArt: UIImageView? = nil
    @IBOutlet var hostAddressLabel: UILabel?
    
    var hostAddress: String = ""
    var hostName: String = ""
    
    private let client: DDJClient = DDJClient.shared
    
    override func viewWillAppear(_ animated: Bool) {
        client.connect(to: hostAddress)
        
        super.viewWillAppear(animated)
        self.hostAddressLabel?.text = hostAddress
        self.serverNameLabel?.text = hostName
    }
    
    func ddjClientHeartbeatTimeout() {
        // TODO
    }
    
    func ddjClient(updatePlaylist: [SPTTrack]) {
        guard let track = updatePlaylist.first else {
            return
        }
        self.nowPlayingLabelTrackName?.text = track.name
        self.nowPlayingLabelTrackAlbum?.text = track.album.name
        self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
        updateAlbumArt(for: track)
    }
    
    func updateAlbumArt(for track: SPTTrack?) {
        guard let t = track else {
            return
        }
        DispatchQueue.global().async {
            guard let image = t.albumArt ?? DDJSPTTools.getAlbumArt(for: t) else {
                return
            }
            self.albumArt?.image = image
        }
    }
}
