//
//  EZSSL.swift
//  DDJiOS
//
//  Created by Eric Miller on 3/15/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import BlueSocket

private class MySSL {
    static var global = MySSL()
    static var config: SSLService.Configuration? {
        get {
            return MySSL.global?.config
        }
    }
    static var service: SSLService? {
        get {
            return MySSL.global?.service
        }
    }
    
    var _config: SSLService.Configuration
    var _service: SSLService
    
    var config: SSLService.Configuration {
        get {
            return _config
        }
    }
    
    var service: SSLService {
        get {
            return _service
        }
    }
    
    init?() {
        let cfg = SSLService.Configuration(withCipherSuite: "ALL")
        self._config = cfg
        self._config.cipherSuite = "ALL"
        do {
            self._service = try SSLService(usingConfiguration: cfg)!
            self._service.skipVerification = true
        } catch {
            print("An error occurred while trying to initialize the SSL service.")
            return nil
        }
    }
}

class EZSSL {
    let socket: Socket
    
    init?() {
        do {
            // This sets SSLService as a delegate to the socket, so the protocol is used automatically.
            self.socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
            // self.socket.delegate = MySSL.service
        } catch let error {
            print("Failed to initialize TCP socket.")
            print(error.localizedDescription)
            
            guard let err = error as? Socket.Error else {
                return nil
            }
            print(err.description)
            
            return nil
        }
    }
}
