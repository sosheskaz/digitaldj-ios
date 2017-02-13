//
// Created by Eric Miller on 2/12/17.
// Copyright (c) 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class DDJSPTTools {
    static func SPTTracksFromIdsOrUris(_ idsOrUris: [String]) -> [SPTTrack]? {
        guard let regex = EZRegex(pattern: "^spotify:track:.+$") else {
            return nil
        }
        let uris = idsOrUris.map( { item -> URL in
            let isUri = regex.test(against: item)
            let uriStr = isUri ? item : "spotify:track:\(item)"
            return URL(string: uriStr)!
        })
        do {
            let tracksRequest = try SPTTrack.createRequest(forTracks: uris, withAccessToken: nil, market: "US")
            let responseData = Alamofire.request(tracksRequest).responseData()
            
            guard let data = responseData.data else {
                return nil
            }
            guard let response = responseData.response else {
                return nil
            }
            
            return try SPTTrack.tracks(from: data, with: response) as? [SPTTrack]
        } catch {
            return nil
        }
    }
    
    private init() {}
}
