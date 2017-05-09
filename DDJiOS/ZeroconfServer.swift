//
// Created by Eric Miller on 10/30/16.
// Copyright (c) 2016 msoe. All rights reserved.
//

import Foundation

class ZeroconfServer {
    private var service: NetService

    private let PORT: Int32 = 52773
    private var name: String
    private let DEFAULT_NAME: String = "Digital DJ"
    private let DOMAIN: String = "local"
    private let TYPE: String = "_ddj._tcp"
    private let DEFAULT_TIMEOUT: TimeInterval = 1.0
    
    public static let shared = ZeroconfServer()

    private init() {
        self.name = DEFAULT_NAME
        self.service = NetService(domain: DOMAIN, type: TYPE, name: name, port: PORT)
    }
    
    public func start(name newName: String) {
        stop()
        self.name = newName
        self.service = NetService(domain: DOMAIN, type: TYPE, name: self.name, port: PORT)
        self.service.publish()
    }
    
    public func start() {
        stop()
        self.service = NetService(domain: DOMAIN, type: TYPE, name: self.name, port: PORT)
        self.service.publish()
    }

    public func stop() {
        self.service.stop()
    }
}
