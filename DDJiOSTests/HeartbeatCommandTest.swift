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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cmd = HeartbeatCommand()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        XCTAssert(des!["command"] as! String == "heartbeat", "Expected=heartbeat Actual=\(des!["command"])")
    }
    
    func testHeartbeatReceipt() {
        let hb = HeartbeatCommand()
        let listener = ClientCommandListener()
        
        var didComplete = false
        
        listener.subscribe(to: .heartbeat, callback: {cmd in
            print("Heartbeat received:")
            print(String(data: cmd.json!, encoding: .utf8)!)
            didComplete = true
        })
        
        let exRes = hb.execute("127.0.0.1")
        
        listener.off()
        
        XCTAssert(exRes)
        XCTAssert(didComplete)
    }
    
}
