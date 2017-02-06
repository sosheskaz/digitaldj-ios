//
//  DDJSPlaylistRequest.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/14/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Alamofire
import Foundation
import WebKit

let isSecure = false
let prtcl = isSecure ? "https" : "http"
let defaultEndpoint: String = "\(prtcl)://digitaldj.us-west-2.elasticbeanstalk.com/api/v1/generateplaylist"

class DDJSPlaylistRequest {
    var endpoint: String = defaultEndpoint
    var endpointUrl: URL
    var session = URLSession(configuration: .default)
    var jsonDict: [String: AnyObject]
    
    convenience init(endpoint: String = defaultEndpoint, oauthTokens: Array<String>) {
        self.init()
        self.endpoint = endpoint
        self.endpointUrl = URL(string: self.endpoint)!
        self.jsonDict = [
            "authTokens": oauthTokens as AnyObject
        ]
    }
    
    init() {
        self.endpointUrl = URL(string: self.endpoint)!
        self.jsonDict = [:]
    }
    
    func doRequestAF(callback: @escaping (Int?, Data?) -> Void) -> Void {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        print("req start")
        do {
        print(String(data: try JSONSerialization.data(withJSONObject: self.jsonDict, options: []), encoding: String.Encoding.utf8) ?? "FAIL")
        } catch {
            print("DOUBLE FAIL")
        }
        
        let queue = DispatchQueue(label: "com.ddj.alamofire-queue", qos: .utility, attributes: [.concurrent])
        let req = Alamofire.request(endpoint, method: .post, parameters: self.jsonDict, encoding: JSONEncoding.default, headers: headers).validate().response(queue: queue, completionHandler: { response in
            print("HIT")
            
            print(String(data: response.data!, encoding: String.Encoding.utf8) ?? "nil")
            callback(response.response?.statusCode, response.data)
        })
        
        req.resume()
    }
    
    func doRequest(callback: @escaping (Any) -> Void) -> Void {
        DispatchQueue.global().async {
            
            var request = URLRequest(url: self.endpointUrl)
            request.httpMethod = "POST"
            do {
                let json = try JSONSerialization.data(withJSONObject: self.jsonDict)
                let bodyString = "\"\(String(data: json, encoding: String.Encoding.utf8)!.replacingOccurrences(of: "\"", with: "'"))\""
                print(bodyString)
                request.allHTTPHeaderFields?["Content-Type"] = "application/text"
                request.httpBody = bodyString.data(using: .utf8)
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
