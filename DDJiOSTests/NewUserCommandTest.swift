//
//  NewUserCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class NewUserCommandTest: XCTestCase {
    private let mockUserId = "imauser"
    private let mockTrackIds = SPTManager.shared.tracks50
    private var cmd: NewUserCommand?
    private let listener = HostCommandListener.shared
    
    override func setUp() {
        super.setUp()
        cmd = NewUserCommand(userId: mockUserId, topTracks: mockTrackIds)
        _ = listener.on()
        usleep(10000)
    }
    
    override func tearDown() {
        super.tearDown()
        listener.off()
    }
    
    func testInit() {
        XCTAssert(cmd!.spotifyId == mockUserId)
        XCTAssert(cmd!.topTracks.elementsEqual(mockTrackIds))
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
        
        XCTAssert(des!["command"] as! String == "newUser", "Expected=newUser Actual=\(String(describing: des!["command"]))")
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["spotifyId"] as! String == mockUserId,
                  "Spotify ID: Expected=\(mockUserId) Actual=\(String(describing: des!["spotifyId"]))")
        XCTAssert((des!["topTracks"] as! [String]).elementsEqual(mockTrackIds), "Queue: Expected=\(mockTrackIds) Actual=\(String(describing: des!["topTracks"]))")
    }
    
    func testSend() {
        class Delegate: HostCommandListenerDelegate {
            var didComplete = false
            
            func hostCommandListener(heartbeatAck: HeartbeatAckCommand) {
                
            }
            func hostCommandListener(newUser: NewUserCommand) {
                print("New User received:")
                print(String(data: newUser.json!, encoding: .utf8)!)
                didComplete = true
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
