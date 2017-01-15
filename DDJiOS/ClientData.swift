//
//  ClientData.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/19/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation

private let userTokenSelectorString = "userToken"

class ClientData {
    public var userToken: String?
    
    init() {
        self.userToken = nil
    }
    
    init?(fromJson json: String) {
        do {
            let data = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions()) as AnyObject
            userToken = (data[userTokenSelectorString] as! String?)
        } catch {
            return nil
        }
    }
    
    convenience init(fromData data: Data) {
        self.init()
        self.userToken = ((data as AnyObject)[userTokenSelectorString] as? String?)!
    }
    
    convenience init(_ userToken: String!) {
        self.init()
        self.userToken = userToken
    }
    
    public func getUserToken() -> String? {
        return self.userToken
    }
    
    public func setUserToken(_ userToken: String?) {
        self.userToken = userToken
    }
    
    public func toJson() -> String? {
        do {
            var encodable: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            encodable[userTokenSelectorString] = self.userToken! as AnyObject!
            
            let data = try JSONSerialization.data(withJSONObject: encodable, options: JSONSerialization.WritingOptions())
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
