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
var authenticatedViewController: UIViewController? = nil

/**
 Authenticates to Spotify. Uses previous auth token if already authenticated,
 or redirects user to login page if appropriate. The passed in SPTAuth is now authenticated,
 and the player is logged in using the authentication. If user does not authenticate successfully,
 detection and recourse is left up to the invoker.
 - parameter player:               The StreamingController to authenticate.
 - parameter auth:                 The SPTAuth object to use and update.
 - parameter sourceViewController: The UIViewController from which this is being called.
 */
func doSpotifyAuthenticate(player: SPTAudioStreamingController?, auth: SPTAuth!, sourceViewController: UIViewController!) -> Void {
    DispatchQueue.main.async(execute: {
        MySpt.shared.touch()
        usleep(10000)
        if (auth.session != nil && (auth.session.isValid())) {
            print("Auth Session Valid")
            MySpt.shared.touch()
            authViewController?.dismiss(animated: true, completion: nil)
            // Use it to log in
            player?.login(withAccessToken:auth.session.accessToken)
        } else {
            print("Auth Session not valid; Presenting Auth Window")
            // Get the URL to the Spotify authorization portal
            let authURL = auth.spotifyWebAuthenticationURL()
            
            authViewController?.dismiss(animated: true, completion: { () -> Void in
                DispatchQueue.main.async(execute: {
                    doSpotifyAuthenticate(player: player!, auth: auth!, sourceViewController: sourceViewController)
                })})
            
            // Present in a SafariViewController
            if(authViewController == nil) {
                authViewController = SFSafariViewController(url: authURL!)
            }
            sourceViewController.present(authViewController!, animated: true, completion:nil)
        }
    })
}

func doSpotifyAuthCallback(error: Error?, session: SPTSession?) {
    
    // dismiss the auth view. Leave it to the previous ViewController to figure out.
    authViewController?.dismiss(animated: true, completion: nil)
}
