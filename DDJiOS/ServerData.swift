//
//  ServerData.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/19/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation

private let tokensName = "userTokens"

class ServerData {
    private var oauthTokens: Set<String> = Set<String>()
    
    convenience init(userTokens: Array<String> = []) {
        self.init()
        self.oauthTokens = Set(userTokens)
    }
    
    convenience init(fromData data: AnyObject) {
        self.init()
        
        self.oauthTokens = Set(data[tokensName] as! Array<String>)
    }
    
    init() {
    }
    
    init?(fromJson json: String) {
        do {
            let data = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions()) as AnyObject
            self.oauthTokens = Set<String>(data[tokensName] as! Array<String>)
        } catch {
            return nil
        }
    }
    
    public func addUserToken(token: String) {
        oauthTokens.insert(token)
    }
    
    public func addUserTokens(tokens: Array<String>) {
        oauthTokens = oauthTokens.union(tokens)
    }
    
    public func removeUserToken(token: String) {
        oauthTokens.remove(token)
    }
    
    public func getUserTokens() -> Array<String> {
        return Array<String>(oauthTokens)
    }
    
    public func clear() {
        oauthTokens.removeAll()
    }
    
    public func toJson() -> String? {
        do {
            var encodable: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            encodable[tokensName] = Array<String>(self.oauthTokens) as AnyObject!
            
            let data = try JSONSerialization.data(withJSONObject: encodable, options: JSONSerialization.WritingOptions())
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
