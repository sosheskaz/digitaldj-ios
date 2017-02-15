//
//  ClientViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientViewController: UIViewController, DDJClientDelegate, UITableViewDataSource, UITableViewDelegate {
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
        self.nowPlayingLabelTrackName?.text = ""
        self.nowPlayingLabelTrackAlbum?.text = ""
        self.nowPlayingLabelTrackArtist?.text = ""
        client.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RemoveUserCommand(userId: MySpt.shared.userId).execute(hostAddress)
    }
    
    func ddjClientHeartbeatTimeout() {
        // TODO
    }
    
    func ddjClient(updatePlaylist: [SPTTrack]) {
        print("CLIENT UPDATE")
        guard let track = updatePlaylist.first else {
            return
        }
        print(track)
        
        DispatchQueue.main.async {
            self.playlistTableView?.reloadData()
            self.nowPlayingLabelTrackName?.text = track.name
            self.nowPlayingLabelTrackAlbum?.text = track.album.name
            self.nowPlayingLabelTrackArtist?.text = track.artists.map({ return ($0 as! SPTPartialArtist).name }).joined(separator: ", ")
            self.updateAlbumArt(for: track)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.playlist.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = client.playlist[indexPath.row + 1].name
        return cell
    }
    
    private func updateAlbumArt(for track: SPTTrack?) {
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
