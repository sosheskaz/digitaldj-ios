//
//  ServerData.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/19/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation

let tokensName = "userTokens"

class ServerData: NSCoding {
    private var oauthTokens: Set<String> = Set<String>()
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.oauthTokens = Set(decoder.decodeObject(forKey: tokensName) as! Array<String>)
    }
    
    convenience init(userTokens: Array<String> = []) {
        self.init()
        self.oauthTokens = Set(userTokens)
    }
    
    convenience init(fromData data: AnyObject) {
        self.init()
        
        self.oauthTokens = Set(data[tokensName] as! Array<String>)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(oauthTokens, forKey: tokensName)
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
    
    public func fill(fromJson json: String) -> Bool{
        do {
            let data = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions()) as AnyObject
            
            self.oauthTokens = self.oauthTokens.union(Set(data[tokensName] as! Array<String>))
        } catch {
            return false
        }
        
        return true
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
