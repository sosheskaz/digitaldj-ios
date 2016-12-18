//
//  DDJSPlaylistRequest.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/14/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import WebKit

let defaultEndpoint: String = "http://digitaldj.us-west-2.elasticbeanstalk.com/api/v1"

class DDJSPlaylistRequest {
    let endpoint: String
    let endpointUrl: URL
    let session = URLSession(configuration: .default)
    var jsonDict: Any
    
    init(endpoint: String = defaultEndpoint, oauthTokens: Array<String>) {
        self.endpoint = endpoint
        self.endpointUrl = URL(string: self.endpoint)!
        self.jsonDict = [
            "authTokens": oauthTokens
        ]
    }
    
    func doRequest(callback: @escaping (Any) -> Void) -> Void {
        DispatchQueue.global().async {
            
            var request = URLRequest(url: self.endpointUrl)
            request.httpMethod = "POST"
            do {
                var json = try JSONSerialization.data(withJSONObject: self.jsonDict)
                let postString = "\"" + String(data: json, encoding: String.Encoding.utf8)! + "\""
            } catch {
                print("uh oh spaggettios")
            }
            
            let task = self.session.dataTask(with: request, completionHandler: { data, response, error in
                print("Doing URLSession DataTask")
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                do {
                    let responseData = try JSONSerialization.jsonObject(with: data, options: [])
                    callback(responseData as! Dictionary<String, Any>)
                } catch {
                    
                }
            })
            
            print("resume")
            // do request
            task.resume()
            
        }
    }
}
