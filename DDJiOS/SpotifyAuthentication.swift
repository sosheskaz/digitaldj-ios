//
//  SpotifyAuthentication.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/9/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import SafariServices

var authViewController: SFSafariViewController? = nil

/**
 Authenticates to Spotify. Uses previous auth token if already authenticated,
 or redirects user to login page if appropriate.
 - parameter player:               The StreamingController to authenticate.
 - parameter auth:                 The SPTAuth object to use and update.
 - parameter sourceViewController: The UIViewController from which this is being called.
 */
func doSpotifyAuthenticate(player: SPTAudioStreamingController?, auth: SPTAuth!, sourceViewController: UIViewController!) -> Void {
    if (auth.session != nil && (auth.session.isValid())) {
        authViewController?.dismiss(animated: true, completion: nil)
        // Use it to log in
        player?.login(withAccessToken:auth.session.accessToken)
    } else {
        // Get the URL to the Spotify authorization portal
        let authURL = auth.spotifyWebAuthenticationURL()
        // Present in a SafariViewController
        authViewController = SFSafariViewController(url: authURL!)
        sourceViewController.present(authViewController!, animated: true, completion:nil)
    }
}
