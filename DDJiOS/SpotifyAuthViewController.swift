//
//  SpotifyAuthViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/7/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import SafariServices

class SpotifyAuthViewController: UIViewController {
    public let CLIENT_ID = "fc6d46c6e95e4c579abd440376ba7555"
    public let CLIENT_SECRET = "b101c807436144c2848f84d2fb26c264"
    public let CALLBACK_URL = "ddj://callback/"
    
    var authViewController: SFSafariViewController
    
    func doAuth() {
        let auth = SPTAuth.defaultInstance()
        auth?.clientID = CLIENT_ID
        auth?.redirectURL = URL(string: CALLBACK_URL)
        auth?.sessionUserDefaultsKey = "current session"
        auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadTopScope]
        if(auth?.session.isValid())! {
            // idk lol
        } else {
            let url: URL = (auth?.spotifyWebAuthenticationURL())!
            self.authViewController = SFSafariViewController(url: url)
            self.present(self.authViewController, animated: true, completion: nil)
        }
        
    }
    
    func authCallback(application: UIApplication, url: URL, options: Dictionary) {
        
    }
}


