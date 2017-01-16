//
//  CommandTestManual.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/15/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class CommandTestManual: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoHeartbeat() {
        let hb = HeartbeatCommand()
        hb.execute("127.0.0.1") // run a listener on port CommandPort.client / 52774 as set at time of writing
    }
    
    func testHeartbeatReceipt() {
        let hb = HeartbeatCommand()
        let listener = CommandRunner(.client)
        
        var didComplete = false
        
        listener.subscribe(to: .heartbeat, callback: {cmd in
            print("Heartbeat received:")
            print(String(data: cmd.json!, encoding: .utf8)!)
            didComplete = true
        })
        
        hb.execute("127.0.0.1")
        
        sleep(2)
        
        listener.off()
        
        XCTAssert(didComplete)
    }
}
