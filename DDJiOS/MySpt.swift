//
//  MySpt.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/29/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import SafariServices
import Alamofire

class MySpt {
    static var shared = MySpt()
    private static let numTracks = 50
    
    private let authLock = DispatchQueue(label: "myspt.authQueue")
    
    private var authViewController: SFSafariViewController? = nil
    private var authenticatedViewController: UIViewController? = nil
    private var myTopTracks: [String] = []
    
    private var _auth = SPTAuth()
    private let scopes: [String] = [SPTAuthStreamingScope, SPTAuthUserReadTopScope, SPTAuthUserReadPrivateScope,
                                    SPTAuthUserLibraryReadScope]
    
    private let authDQ = DispatchQueue(label: "MySpt_auth_queue")
    private var authIsPresenting = false
    private var profile: SPTUser?
    
    let player = SPTAudioStreamingController.sharedInstance()
    
    private init() {
        self.initializeAuth()
    }
    
    // MARK: Public properties
    
    var token: String? {
        get {
            
            let token = self.session?.accessToken
            
            return token
        }
    }
    
    var userId: String! {
        get {
            return self.session?.canonicalUsername
        }
    }
    
    var session: SPTSession? {
        get {
            return self.auth.session
        }
    }
    
    var auth: SPTAuth {
        get {
            return self._auth
        }
    }
    
    var topTracks: [String] {
        get {
            return self.myTopTracks
        }
    }
    
    var loggedIn: Bool {
        get {
            return self.session?.isValid() ?? false
        }
    }
    
    var authUrl: URL {
        get {
            return self.auth.spotifyWebAuthenticationURL()
        }
    }
    
    // MARK: general public functions
    
    func touch() { }
    
    func login(callback: (() -> Void)? = nil) {
        self.initializeAuth()
        self.ensureAuthenticated(callback)
    }
    
    func logout() {
        self._auth = SPTAuth()
    }
    
    // MARK: Auth handling
    
    func doSpotifyAuthCallback(error: Error?, session: SPTSession?) {
        if error != nil {
            log.error(String(describing: error?.localizedDescription))
            log.error(error.debugDescription)
        }
        // dismiss the auth view. Leave it to the previous ViewController to figure out.
        self.dismissAuthWindow()
    }
    
    private func initializeAuth() {
        self.auth.clientID = CLIENT_ID
        self.auth.redirectURL = URL(string: CALLBACK_URL)
        self.auth.sessionUserDefaultsKey = "current SPT session"
        self.auth.requestedScopes = self.scopes;
    }
    
    private func refreshToken() {
        log.info("Trying for refresh token...")
        guard self.session?.encryptedRefreshToken != nil else {
            log.warning("No refresh token found.")
            return
        }
        log.info("Attempting to renew session")
        SPTAuth.renewSession(self._auth)(self.session, callback: nil)
    }
    
    private func ensureAuthenticated(_ callback: (() -> Void)? = nil) -> Void {
        self.authDQ.async {
            guard let session = self.auth.session else {
                log.verbose("Session does not exist. Showing auth window.")
                self.presentAuthWindow()
                self.afterAuthenticated()
                callback?()
                return
            }
            guard session.isValid() else {
                log.verbose("Session is not valid. Showing auth window.")
                self.presentAuthWindow()
                self.afterAuthenticated()
                callback?()
                return
            }
            log.info("Already authenticated.")
            
            self.afterAuthenticated()
            guard let cb = callback else {
                return
            }
            cb()
        }
    }
    
    private func afterAuthenticated() {
        log.info("Auth Session Valid - fetching tracks.")
        self.fetchTopTracks()
        log.info("Fetched tracks.")
        
        self.fetchUserProfile({ user, error in
            guard error == nil else {
                return
            }
            guard user?.product == SPTProduct.premium else {
                log.warning("User is not a premium user. Cannot stream music.")
                return
            }
            
            DispatchQueue.main.async {
                log.info("User is a premium user. Logging into player.")
                self.player?.login(withAccessToken: self.session!.accessToken)
                log.info("Logged into player.")
            }
        })
        
        self.dismissAuthWindow()
        // Use it to log in
    }
    
    private func fetchUserProfile(_ callback: @escaping ((SPTUser?, Error?) -> Void)) {
        do {
            let sptRequest = try SPTUser.createRequestForCurrentUser(withAccessToken: self.token) as URLRequestConvertible
            let request = Alamofire.request(sptRequest)
            request.responseJSON(completionHandler: {response in
                guard let result = response.result.value as AnyObject? else {
                    log.error("Result was nil.")
                    log.error("Error: \(String(describing: response.error))")
                    log.error("Was success? \(response.result.isSuccess)")
                    return
                }
                do {
                    log.info("Got user profile.")
                    self.profile = try SPTUser(fromDecodedJSON: result)
                    callback(self.profile, nil)
                } catch let error {
                    log.error("Failed to decode SPTUser.")
                    log.error(error.localizedDescription)
                    callback(nil, error)
                }
            }).resume()
        } catch let error {
            log.error("Unanticipated error. Send this log to Eric.")
            log.error(error.localizedDescription)
            callback(nil, error)
        }
    }
    
    private func presentAuthWindow() {
        DispatchQueue.main.async {
            if(self.authIsPresenting) {
                return
            }
            log.info("Starting Auth VC.")
            
            let sourceViewController = UIApplication.shared.keyWindow?.rootViewController
            
            if self.authViewController == sourceViewController {
                log.info("AuthViewController already active.")
                return
            }
            
            let authURL = self.auth.spotifyWebAuthenticationURL()
            
            // Dismiss it, just in case it's active. Otherwise recursion can get stuck without a base case.
            self.dismissAuthWindow(completion: {
                self.ensureAuthenticated()
            })
            
            if(self.authViewController == nil) {
                self.authViewController = SFSafariViewController(url: authURL!)
            }
            self.authIsPresenting = true
            
            sourceViewController?.present(self.authViewController!, animated: true, completion:nil)
            
            log.info("Exiting Auth VC")
        }
    }
    
    private func dismissAuthWindow(completion: (() -> Void)? = nil) {
        self.authViewController?.dismiss(animated: true, completion: {
            self.authIsPresenting = false
            guard let closure = completion else {
                return
            }
            closure()
        })
    }
    
    // MARK: API Helpers
    
    private func fetchTopTracks() {
        while(!(self.session?.isValid() ?? false) ) {
            sleep(1)
        }
        
        do {
            let req = try SPTRequest.createRequest(for: URL(string: "https://api.spotify.com/v1/me/top/tracks"), withAccessToken: self.token, httpMethod: "GET", values: ["limit": MySpt.numTracks], valueBodyIsJSON: false, sendDataAsQueryString: true)
            
            log.info("Fetching tracks for \(self.userId ?? "nil") with token \(self.token ?? "nil")")
            
            let response = Alamofire.request(req).responseJSON()
            
            guard response.result.error == nil else {
                log.error("Coult not get top tracks!")
                log.error("Error: \(String(describing: response.result.error))")
                return
            }
            
            guard let data = response.data else {
                log.error("Coult not get top tracks because data is not AnyObject!")
                log.error("Error: \(String(describing: response.result.error?.localizedDescription))")
                return
            }
            
            var finalTracks: [String] = []
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                let toAppend = (json["items"] as! [AnyObject]).map {
                    return $0["id"] as! String
                }
                finalTracks += toAppend
            } catch {
                log.error("Could not deserialize JSON!")
            }
            
            // fill in extra items with spares from their library
            if(finalTracks.count < MySpt.numTracks) {
                do {
                    log.info("Not enough top tracks found (\(finalTracks.count)), pulling from library.")
                    let limit = 50 // there is a hard limit on 50.
                    let req2 = try SPTRequest.createRequest(for: URL(string: "https://api.spotify.com/v1/me/tracks"), withAccessToken: self.token, httpMethod: "GET", values: ["limit": limit], valueBodyIsJSON: false, sendDataAsQueryString: true)
                    
                    let response2 = Alamofire.request(req2).responseJSON()
                    
                    guard response2.result.error == nil else {
                        log.error("Coult not pull supplementary tracks from library!")
                        log.error("Error: \(String(describing: response.result.error))")
                        return
                    }
                    
                    guard response2.result.isSuccess else {
                        log.error("Coult not pull supplementary tracks from library for unknown reason!")
                        log.error(String(data: response2.data!, encoding: .utf8) ?? "nil")
                        return
                    }
                    
                    guard let data = response2.data else {
                        log.error("Coult not get top tracks because data is not AnyObject!")
                        log.error("Error: \(String(describing: response2.result.error))")
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                        
                        let jsonItems: [AnyObject] = json["items"] as! [AnyObject]
                        
                        let trimmed = jsonItems.map({ jsonItem in
                            return ((jsonItem as AnyObject)["track"] as AnyObject)["id"]!!
                        }).filter({ jsonItem in
                            do {
                                return (jsonItem as? String) != nil
                                // The compiler lies that this is not necessary.
                            } catch let error {
                                log.error(error.localizedDescription)
                                return false
                            }
                        }).shuffled()
                        
                        let trimmedArr = trimmed as! [String]
                        finalTracks += trimmedArr.take((min(trimmedArr.count, MySpt.numTracks - finalTracks.count)))
                        
                        self.myTopTracks = finalTracks
                    } catch let error {
                        log.error("Could not deserialize JSON 2!")
                        log.error(error.localizedDescription)
                    }
                } catch let error {
                    log.error("Failed to make backup songs request!")
                    log.error(error.localizedDescription)
                }
            } else {
                if(finalTracks.count > MySpt.numTracks) {
                    // make sure we only have correct number of items
                    finalTracks = Array(finalTracks.dropLast(finalTracks.count - MySpt.numTracks))
                }
                self.myTopTracks = finalTracks
            }
        } catch let error {
            log.error("error!")
            log.error(error.localizedDescription)
        }
    }
}
