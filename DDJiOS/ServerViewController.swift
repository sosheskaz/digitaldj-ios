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

class ServerViewController: UIViewController {
    let player: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    let auth = SPTAuth.defaultInstance()
    
    private let zc: ZeroconfServer = ZeroconfServer()
    private let host = DDJHost.shared
    private let DEFAULT_ZC_NAME: String = "iOS Digital DJ"
    
    private var zcName: String
    private var isStarted = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        host.clearSubscribers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        host.clearSubscribers()
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
}

protocol ServerViewControllerNameDelegate {
    var name: String {get}
}
