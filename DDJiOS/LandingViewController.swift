//
//  LandingViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/12/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class LandingViewController: UIViewController {
    var player: SPTAudioStreamingController?
    var auth: SPTAuth?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidLoad")


        self.player = SPTAudioStreamingController.sharedInstance()
        self.auth = SPTAuth.defaultInstance()
        doSpotifyAuthenticate(player: self.player!, auth: self.auth!, sourceViewController: self)
        print("ViewDidLoad 2")
    }
}
