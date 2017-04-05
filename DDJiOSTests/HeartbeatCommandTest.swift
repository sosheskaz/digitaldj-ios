//
//  HeartbeatCommandTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class HeartbeatCommandTest: XCTestCase {
    var cmd: HeartbeatCommand?
    
    let listener = ClientCommandListener.shared
    
    override func setUp() {
        super.setUp()
        cmd = HeartbeatCommand()
        _ = listener.on()
        usleep(10000)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJson() {
        let data = cmd!.json
        XCTAssert(data != nil, "data was nil")
        
        var des: [String:AnyObject]? = nil
        do {
            des = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
        } catch {
            XCTAssert(false, "Deserialization failed.")
            return
        }
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["command"] as! String == "heartbeat", "Expected=heartbeat Actual=\(String(describing: des!["command"]))")
    }
    
    func testHeartbeatReceipt() {
        let hb = HeartbeatCommand()
        
        var didComplete = false
        
        listener.subscribe(to: .heartbeat, callback: {cmd in
            print("Heartbeat received:")
            print(String(data: cmd.json!, encoding: .utf8)!)
            didComplete = true
        })
        
        let exRes = hb.execute("127.0.0.1")
        sleep(1)
        
        XCTAssert(exRes)
        XCTAssert(didComplete)
    }
    
}
