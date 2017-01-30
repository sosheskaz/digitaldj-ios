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


private let CLIENT_ID = "fc6d46c6e95e4c579abd440376ba7555"
private let CLIENT_SECRET = "b101c807436144c2848f84d2fb26c264"
private let CALLBACK_URL = "ddj://callback/"

class MySpt {
    static var shared = MySpt()
    private static let numTracks = 50
    
    private let authLock = DispatchQueue(label: "myspt.authQueue")
    
    private var authViewController: SFSafariViewController? = nil
    private var authenticatedViewController: UIViewController? = nil
    private var myTopTracks: [String] = []
    
    private init() {
        SPTAuth.defaultInstance()
        // The client ID you got from the developer site
        SPTAuth.defaultInstance()!.clientID = CLIENT_ID
        // The redirect URL as you entered it at the developer site
        SPTAuth.defaultInstance()!.redirectURL = URL(string: CALLBACK_URL)
        // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
        SPTAuth.defaultInstance()!.sessionUserDefaultsKey = "current session"
        // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
        SPTAuth.defaultInstance()!.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadTopScope, SPTAuthUserReadPrivateScope];
        
        print(SPTAuth.defaultInstance().session)
        self.startExpirationDaemon()
        self.fetchTopTracks()
    }
    
    var token: String! {
        get {
            
            let token = self.session.accessToken
            
            return token
        }
    }
    
    var userId: String! {
        get {
            return session.canonicalUsername
        }
    }
    
    var session: SPTSession {
        get {
            return SPTAuth.defaultInstance().session
        }
    }
    
    func touch() { }
    
    private func startExpirationDaemon() {
        DispatchQueue.global().async {
            while(true) {
                guard let expireTime = self.session.expirationDate else {
                    sleep(1) // we're waiting for auth.
                    continue
                }
                
                let secondsUntilExpireTime = max(expireTime.seconds(from: Date()), 0)
                sleep(UInt32(secondsUntilExpireTime))
                self.refreshToken()
            }
        }
    }
    
    private func refreshToken() {
        print("Trying for refresh token...")
        guard self.session.encryptedRefreshToken != nil else {
            print("No refresh token found.")
            return
        }
        print("Attempting to renew session")
        SPTAuth.renewSession(SPTAuth.defaultInstance())(self.session, callback: nil)
    }
    
    private func fetchTopTracks() {
        DispatchQueue.global().async {
            while(!self.session.isValid()) {
                sleep(1)
            }
            
            do {
                let req = try SPTRequest.createRequest(for: URL(string: "https://api.spotify.com/v1/me/top/tracks"), withAccessToken: self.token, httpMethod: "GET", values: ["limit": MySpt.numTracks], valueBodyIsJSON: false, sendDataAsQueryString: true)
                
                Alamofire.request(req).responseJSON(completionHandler: {response in
                    guard response.result.error == nil else {
                        print("Coult not get top tracks!")
                        print("Error: \(response.result.error)")
                        return
                    }
                    
                    guard let data = response.data else {
                        print("Coult not get top tracks because data is not AnyObject!")
                        print("Error: \(response.result.error)")
                        return
                    }
                    
                    var finalTracks: [String] = []
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                        print(json)
                        finalTracks.append(contentsOf: json["items"] as! Array)
                    } catch {
                        print("Could not deserialize JSON!")
                    }
                    
                    // fill in extra items with spares from their library
                    if(finalTracks.count < MySpt.numTracks) {
                        do {
                            let req2 = try SPTRequest.createRequest(for: URL(string: "https://api.spotify.com/v1/me/top/tracks"), withAccessToken: self.token, httpMethod: "GET", values: ["limit": MySpt.numTracks], valueBodyIsJSON: false, sendDataAsQueryString: true)
                            
                            Alamofire.request(req2).responseJSON(completionHandler: {response in
                                guard response.result.error == nil else {
                                    print("Coult not get top tracks!")
                                    print("Error: \(response.result.error)")
                                    return
                                }
                                
                                guard let data = response.data else {
                                    print("Coult not get top tracks because data is not AnyObject!")
                                    print("Error: \(response.result.error)")
                                    return
                                }
                                
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                                    let jsonItems: [AnyObject] = json["items"] as! [AnyObject]
                                    let trimmed = jsonItems.map({ jsonItem in
                                        return ((jsonItem as AnyObject)["track"] as AnyObject)["id"]
                                    }).filter({ jsonItem in
                                        do {
                                            return (jsonItem as? String) != nil
                                            // The compiler lies that this is not necessary.
                                        } catch {
                                            return false
                                        }
                                    }).shuffled()
                                    let trimmedArr = Array(trimmed) as! [String]
                                    
                                    finalTracks.append(contentsOf: trimmedArr.take(min(trimmedArr.count, MySpt.numTracks - finalTracks.count)))
                                    
                                    self.myTopTracks = finalTracks
                                    
                                    print(self.myTopTracks)
                                } catch {
                                    print("Could not deserialize JSON 2!")
                                }
                            }).resume()
                        } catch {
                            print("Failed to make backup songs request!")
                        }
                    } else {
                        if(finalTracks.count > MySpt.numTracks) {
                            // make sure we only have 50 items
                            finalTracks = Array(finalTracks.dropLast(finalTracks.count - MySpt.numTracks))
                        }
                        self.myTopTracks = finalTracks
                    }
                }).resume()
            } catch {
                print("error!")
            }
        }
    }
    
    var topTracks: [String] {
        get {
            return self.myTopTracks
        }
    }
}
