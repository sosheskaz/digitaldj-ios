//
//  EZSSL.swift
//  DDJiOS
//
//  Created by Eric Miller on 3/15/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Socket
import Security

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
    var _service: SSLService?
    
    var config: SSLService.Configuration {
        get {
            return _config
        }
    }
    
    var service: SSLService {
        get {
            return _service!
        }
    }
    
    init?() {
        let cfg = SSLService.Configuration(/*withCipherSuite: "ALL"*/)
        
        //var err: UnsafeMutablePointer<Unmanaged<CFError>?>?
        //print(SecKeyCreateRandomKey(nil, err))
        self._config = cfg
        // self._config.cipherSuite = "ALL"
        do {
            self._service = try SSLService(usingConfiguration: cfg)!
            //self._service?.skipVerification = true
        } catch let error as SSLError {
            log.error("An error occurred while trying to initialize the SSL service.")
            log.error(error.description)
        } catch let error {
            log.error("An error occurred while trying to initialize the SSL service.")
            log.error(error.localizedDescription)
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
            // self.socket.enableSSL()
        } catch let error as Socket.Error {
            log.error("Failed to initialize TCP socket.")
            log.error(error.description)
            return nil
        } catch let error {
            log.error("Failed to initialize TCP socket.")
            log.error(error.localizedDescription)
            
            return nil
        }
    }
}

extension Socket {
    func enableSSL() {
        do {
            let service = try SSLService(usingConfiguration: MySSL.config!)!
            self.delegate = service
        } catch let error as SSLError {
            log.error("An error occurred while trying to initialize the SSL service.")
            log.error(error.description)
        } catch let error {
            log.error("An error occurred while trying to initialize the SSL service.")
            log.error(error.localizedDescription)
        }
    }
}
