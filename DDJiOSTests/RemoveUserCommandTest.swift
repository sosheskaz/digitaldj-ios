//
//  NewUserCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class RemoveUserCommandTest: XCTestCase {
    private let mockUserId = "imauser"
    private var cmd: RemoveUserCommand?
    let listener = HostCommandListener.shared
    
    override func setUp() {
        super.setUp()
        cmd = RemoveUserCommand(userId: mockUserId)
        _ = listener.on()
        usleep(10000)
    }
    
    override func tearDown() {
        super.tearDown()
        listener.off()
    }
    
    func testInit() {
        XCTAssert(cmd!.spotifyId == mockUserId)
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
        
        XCTAssert(des!["command"] as! String == "removeUser", "Expected=removeUser Actual=\(String(describing: des!["command"]))")
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["spotifyId"] as! String == mockUserId,
                  "Spotify ID: Expected=\(mockUserId) Actual=\(String(describing: des!["spotifyId"]))")
    }
    
    func testSend() {
        class Delegate: HostCommandListenerDelegate {
            var didComplete = false
            
            func hostCommandListener(heartbeatAck: HeartbeatAckCommand) {
                
            }
            func hostCommandListener(newUser: NewUserCommand) {
            }
            func hostCommandListener(removeUserCommand: RemoveUserCommand) {
                didComplete = true
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
