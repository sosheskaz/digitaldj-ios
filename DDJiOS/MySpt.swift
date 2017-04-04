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
    
    private init() {
        self.fetchTopTracks()
    }
    
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
            do {
                return SPTAuth.defaultInstance()?.session
            } catch {
                return nil
            }
        }
    }
    
    func logout() {
        let cookies = HTTPCookieStorage.shared.cookies!
        for cookie in cookies {
            if cookie.domain.hasSuffix("spotify.com") {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        SPTAudioStreamingController.sharedInstance().logout()
    }
    
    func touch() { }
    
    private func refreshToken() {
        print("Trying for refresh token...")
        guard self.session?.encryptedRefreshToken != nil else {
            print("No refresh token found.")
            return
        }
        print("Attempting to renew session")
        SPTAuth.renewSession(SPTAuth.defaultInstance())(self.session, callback: nil)
    }
    
    private func fetchTopTracks() {
        DispatchQueue.global().async {
            while(!(self.session?.isValid() ?? false) ) {
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
                        let toAppend = (json["items"] as! [AnyObject]).map {
                            return $0["id"] as! String
                        }
                        finalTracks += toAppend
                    } catch {
                        print("Could not deserialize JSON!")
                    }
                    
                    // fill in extra items with spares from their library
                    if(finalTracks.count < MySpt.numTracks) {
                        do {
                            let req2 = try SPTRequest.createRequest(for: URL(string: "https://api.spotify.com/v1/me/tracks"), withAccessToken: self.token, httpMethod: "GET", values: ["limit": MySpt.numTracks], valueBodyIsJSON: false, sendDataAsQueryString: true)
                            
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
                                    print(jsonItems)
                                    let trimmed = jsonItems.map({ jsonItem in
                                        return ((jsonItem as AnyObject)["track"] as AnyObject)["id"]!!
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
