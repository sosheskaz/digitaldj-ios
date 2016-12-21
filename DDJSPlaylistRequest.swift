//
//  DDJSPlaylistRequest.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/14/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import WebKit

let defaultEndpoint: String = "https://DigitalDJ-1142864711.us-west-2.elb.amazonaws.com"

class DDJSPlaylistRequest {
    var endpoint: String = defaultEndpoint
    var endpointUrl: URL
    var session = URLSession(configuration: .default)
    var jsonDict: Any
    
    convenience init(endpoint: String = defaultEndpoint, oauthTokens: Array<String>) {
        self.init()
        self.endpoint = endpoint
        self.endpointUrl = URL(string: self.endpoint)!
        self.jsonDict = [
            "authTokens": oauthTokens
        ]
    }
    
    init() {
        self.endpointUrl = URL(string: self.endpoint)!
        self.jsonDict = []
    }
    
    func doRequest(callback: @escaping (Any) -> Void) -> Void {
        DispatchQueue.global().async {
            
            var request = URLRequest(url: self.endpointUrl)
            request.httpMethod = "POST"
            do {
                let json = try JSONSerialization.data(withJSONObject: self.jsonDict)
                let postString = "\"" + String(data: json, encoding: String.Encoding.utf8)! + "\""
                request.httpBody = postString.data(using: String.Encoding.utf8)
            } catch {
                print("uh oh spaggettios")
            }
            
            let task = self.session.dataTask(with: request, completionHandler: { data, response, error in
                print("Doing URLSession DataTask")
                print(data == nil)
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error!)")
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
