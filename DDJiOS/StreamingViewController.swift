//
//  StreamingViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/12/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class StreamingViewController : UIViewController {
    let player: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.setIsPlaying(false, callback: nil)
    }
}
