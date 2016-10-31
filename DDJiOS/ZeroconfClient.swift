//
//  ZeroconfClient.swift
//  DDJiOS
//
//  Created by Eric Miller on 10/30/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation

public class ZeroconfClient {
    let PORT: UInt16 = 52773
    let SERVICE_NAME: String = "ddj"
    let DOMAIN: String = "local"
    let TYPE: String = "_ddj._tcp"
    let DEFAULT_TIMEOUT: TimeInterval = 1.0

    private var netServiceBrowser: NetServiceBrowser
    private var netServiceDelegate: ZeroconfDelegate
    private var data: ZeroconfData
    
    init() {
        self.netServiceBrowser = NetServiceBrowser()
        self.data = ZeroconfData()
        self.netServiceDelegate = ZeroconfDelegate(zeroconfData: self.data)
        self.netServiceBrowser.delegate = netServiceDelegate
        self.netServiceBrowser.searchForServices(ofType: TYPE, inDomain: DOMAIN)
    }

    public func searchForServices() {
        self.netServiceBrowser.searchForServices(ofType: TYPE, inDomain: DOMAIN)
    }

    public func clear() {
        self.data.discoveredServices = Array<NetService>()
    }
    
    public func getFoundServices() -> Array<NetService> {
        return self.data.discoveredServices
    }
}

private class ZeroconfData {
    var discoveredServices: Array<NetService>
    
    init() {
        discoveredServices = Array<NetService>()
    }
}

private class ZeroconfDelegate: NSObject, NetServiceBrowserDelegate {
    let data: ZeroconfData
    
    init(zeroconfData: ZeroconfData) {
        self.data = zeroconfData
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.append(sender)
        }
        
        #if DEBUG
            print("netServiceDidResolveAddress: " + sender.hostName!)
        #endif
    }
    
    func netServiceDidStop(_ sender: NetService) {
        let index: Int = self.data.discoveredServices.index(of: sender)!;
        
        #if DEBUG
            print("netServiceDidStop: " + sender.hostName!)
        #endif
        
        if(index < 0) {
            return
        }
        self.data.discoveredServices.remove(at: index)
    }

    func netServiceDidPublish(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.append(sender)
        }
        #if DEBUG
        print("netServiceDidPublish: " + sender.hostName!)
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
