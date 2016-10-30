//
//  ZeroconfClient.swift
//  DDJiOS
//
//  Created by Eric Miller on 10/30/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation

class ZeroconfClient {
    var netServiceBrowser: NetServiceBrowser
    var netServiceDelegate: NetServiceDelegate
    var data: ZeroconfData
    
    init() {
        self.netServiceBrowser = NetServiceBrowser()
        self.data = ZeroconfData()
    }
}

class ZeroconfData {
    let PORT: UInt16 = 52773
    let SERVICE_NAME: String = "ddj"
    let DOMAIN: String = "local"
    let TYPE: String = "_ddj._tcp"
    let DEFAULT_TIMEOUT: TimeInterval = 1.0
    
    let discoveredServices: Set<NetService>
    
    init() {
        discoveredServices = MutableSet<NetService>()
    }
}

class ZeroconfDelegate: NetServiceDelegate {
    let data: ZeroconfData
    
    init(zeroconfData: ZeroconfData) {
        self.data = zeroconfData
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.add(sender)
        }
        
        #if DEBUG
            print("netServiceDidResolveAddress: " + sender.hostName)
        #endif
    }
    
    func netServiceDidStop(_ sender: NetService) {
        let index: Int = self.data.discoveredServices.index(of: sender)!;
        
        #if DEBUG
            print("netServiceDidStop: " + sender.hostName)
        #endif
        
        if(index < 0) {
            return
        }
        self.data.discoveredServices.remove(at: index)
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.add(sender)
        }
        #if DEBUG
        print("netServiceDidPublish: " + sender.hostName)
        #endif
    }
    
    func netServiceWillPublish(_ sender: NetService) {
        return
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        return
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        return
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        return
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        return
    }
    
    func netServiceWillResolve(_ sender: NetService) {
        return
    }
}
