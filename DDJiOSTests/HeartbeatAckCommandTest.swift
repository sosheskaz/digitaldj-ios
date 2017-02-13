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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cmd = HeartbeatAckCommand()
        listener.on()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        listener.off()
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
        
        let exRes = cmd!.execute("127.0.0.1")
        sleep(1)
        
        XCTAssert(exRes)
        XCTAssert(d.didComplete)
    }
}
