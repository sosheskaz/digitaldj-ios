//
//  HeartbeatCommandTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class HeartbeatTimeoutCommandTest: XCTestCase {
    var cmd: HeartbeatTimeoutCommand?
    let jsonObj = ["from":"127.0.0.1"]
    var sampleData: Data?
    let listener = ClientCommandListener.shared
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cmd = HeartbeatTimeoutCommand()
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
        XCTAssert(des!["command"] as! String == "heartbeatTimeout", "Expected=heartbeatTimeout Actual=\(des!["command"])")
    }
    
    func testSend() {
        class Delegate: ClientCommandListenerDelegate {
            var didComplete = false
            
            func clientCommandListener(heartbeat: HeartbeatCommand) {
                
            }
            func clientCommandListener(heartbeatTimeout: HeartbeatTimeoutCommand) {
                didComplete = true
            }
            func clientCommandListener(updatePlaylist: UpdatePlaylistCommand) {

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
