//
// Created by Eric Miller on 2/12/17.
// Copyright (c) 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

class DDJSPTTools {
    static func SPTTracksFromIdsOrUris(_ idsOrUris: [String]) -> [SPTTrack]? {
        guard let regex = EZRegex(pattern: "^spotify:track:.+$") else {
            print("Regex failed to init.")
            return nil
        }
        let uris = idsOrUris.map( { item -> URL in
            let isUri = regex.test(against: item)
            let uriStr = isUri ? item : "spotify:track:\(item)"
            return URL(string: uriStr)!
        })
        do {
            let accessToken = MySpt.shared.session?.accessToken
            let market = accessToken == nil ? "US" : SPTMarketFromToken
            
            let tracksRequest = try SPTTrack.createRequest(forTracks: uris, withAccessToken: accessToken, market: market)
            let responseData = Alamofire.request(tracksRequest).responseData()
            
            guard let data = responseData.data else {
                print(responseData.result.error)
                return nil
            }
            guard let response = responseData.response else {
                print(responseData.result.error)
                return nil
            }
            
            guard let tracks = try SPTTrack.tracks(from: data, with: response) as? [SPTTrack] else {
                return nil
            }
            
            for track in tracks {
                getAlbumArt(for: track, callback: { image in
                    track.albumArt = image
                })
            }
            
            return tracks
        } catch {
            print("An error occurred.")
            return nil
        }
    }
    
    static func getAlbumArt(for track: SPTTrack) -> UIImage? {
        let imageUrl = track.album.largestCover.imageURL
        let data = Alamofire.request(imageUrl!).responseData()
        let image = UIImage(data: data.data!)
        return image
    }
    
    static func getAlbumArt(for track: SPTTrack, callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let image = getAlbumArt(for: track)
            callback(image)
        }
    }
    
    private init() {}
}

extension SPTTrack {
    private struct associatedKeys {
        static var source: UIImage?
    }
    
    var albumArt: UIImage? {
        get {
            guard let value = objc_getAssociatedObject(self, &associatedKeys.source) as? UIImage? else {
                return nil
            }
            return value
        }
        set(value) {
            objc_setAssociatedObject(self, &associatedKeys.source, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
