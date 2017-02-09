//
//  SrvRemoveUserTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/8/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class SrvRemoveUserTest: XCTestCase {
    
    var sessionId: String?
    var userId: String?
    
    override func setUp() {
        super.setUp()
        let nsCmd = ServerNewSessionCommand()
        self.sessionId = ServerNewSessionCommand.getValue(from: nsCmd.executeSync().data)
        print("New Session: \(ServerNewSessionCommand.getValue(from: nsCmd.executeSync().data))")
        
        let nuCmd = ServerNewUserCommand(tracks: ["6Fbsun5UAWFjeBpRatOITI", "06WPoSERagUDPT4DnjCK1S"], sessionId: self.sessionId!)
        self.userId = ServerNewUserCommand.getValue(from: nuCmd.executeSync().data)
        print("User ID: \(self.userId!)")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(sessionId != nil) {
            _ = ServerEndSessionCommand(sessionId: self.sessionId!).executeSync()
            sessionId = nil
        }
    }
    
    func testRemoveUser() {
        guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }
        guard let userId = self.userId else {
            XCTFail("userId was nil; setup failed.")
            return
        }
        let ruCmd = ServerRemoveUserCommand.init(userId, sessionId: sessionId)
        let res = ruCmd.executeSync()
        let success = ServerRemoveUserCommand.getValue(from: res.data)
        if(!success) {
            print(String(data: res.data!, encoding: .utf8)!)
        }
        XCTAssert(success)
    }
    
    func testRemoveUserFailure() {
        let userId = "not-a-real-id"
        let ruCmd = ServerRemoveUserCommand(userId, sessionId: sessionId!)
        let didfail = !ServerRemoveUserCommand.getValue(from: ruCmd.executeSync().data)
        XCTAssert(didfail)
    }
    
}
