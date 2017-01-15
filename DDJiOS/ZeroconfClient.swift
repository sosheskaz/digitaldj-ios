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
        self.data.discoveredServices = Set<NetService>()
    }
    
    public func getFoundServices() -> Set<NetService> {
        print("zcgfs")
        return self.data.discoveredServices
    }
}

private class ZeroconfData {
    var discoveredServices: Set<NetService>
    
    init() {
        discoveredServices = Set<NetService>()
    }
}

private class ZeroconfDelegate: NSObject, NetServiceBrowserDelegate {
    let data: ZeroconfData
    
    init(zeroconfData: ZeroconfData) {
        print("delegate initialized.")
        self.data = zeroconfData
    }

    func netServiceDidPublish(_ sender: NetService) {
        if(!self.data.discoveredServices.contains(sender)) {
            self.data.discoveredServices.insert(sender)
        }
        
        print("netServiceDidPublish: " + sender.hostName!)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        self.data.discoveredServices.insert(service)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        self.data.discoveredServices.remove(service)
    }

}
