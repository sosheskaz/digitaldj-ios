//
//  HeartbeatCommandTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class HeartbeatAckCommandTest: XCTestCase {
    var cmd: HeartbeatAckCommand?
    let listener = HostCommandListener.shared
    
    override func setUp() {
        super.setUp()
        cmd = HeartbeatAckCommand()
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
        XCTAssert(des!["command"] as! String == "heartbeatAck", "Expected=heartbeatAck Actual=\(des!["command"])")
    }
    
    func testSend() {
        class Delegate: HostCommandListenerDelegate {
            var didComplete = false
            
            func hostCommandListener(heartbeatAck: HeartbeatAckCommand) {
                didComplete = true
            }
            func hostCommandListener(newUser: NewUserCommand) {
            }
            func hostCommandListener(removeUserCommand: RemoveUserCommand) {
                
            }
        }
        let d = Delegate()
        listener.delegate = d
        
        print("Executing command")
        let exRes = cmd!.execute("127.0.0.1")
        sleep(1)
        
        XCTAssert(exRes)
        XCTAssert(d.didComplete)
    }
}
