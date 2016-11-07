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
        self.netServiceBrowser.delegate = self.netServiceDelegate
        self.netServiceBrowser.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.netServiceBrowser.searchForServices(ofType: TYPE, inDomain: DOMAIN)
        print("zcinit")
    }

    public func clear() {
        print("zcc")
        self.data.discoveredServices = Array<NetService>()
    }
    
    public func getFoundServices() -> Array<NetService> {
        print("zcgfs")
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
        print("delegate initialized.")
        self.data = zeroconfData
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.append(sender)
        }
        
        print("netServiceDidResolveAddress: " + sender.hostName!)
    }
    
    func netServiceDidStop(_ sender: NetService) {
        let index: Int = self.data.discoveredServices.index(of: sender)!;
        
        print("netServiceDidStop: " + sender.hostName!)
        
        if(index < 0) {
            return
        }
        self.data.discoveredServices.remove(at: index)
    }

    func netServiceDidPublish(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.append(sender)
        }
        print("netServiceDidPublish: " + sender.hostName!)
    }
    
    func netServiceWillPublish(_ sender: NetService) {
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("DidNotResolve")
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
    }
    
    func netServiceWillResolve(_ sender: NetService) {
    }

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("didstop")
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        print(errorDict)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didfind")
        self.data.discoveredServices.append(service)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
    }

}
