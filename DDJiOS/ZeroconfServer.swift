//
// Created by Eric Miller on 10/30/16.
// Copyright (c) 2016 msoe. All rights reserved.
//

import Foundation

class ZeroconfServer {
    private var service: NetService

    let PORT: Int32 = 52773
    let SERVICE_NAME: String = "ddj"
    let DOMAIN: String = "local"
    let TYPE: String = "_ddj._tcp"
    let DEFAULT_TIMEOUT: TimeInterval = 1.0

    init() {
        service = NetService(domain: DOMAIN, type: TYPE, name: SERVICE_NAME, port: PORT)
    }

    func start() {
        service.publish()
    }

    func stop() {
        service.stop()
    }
}
