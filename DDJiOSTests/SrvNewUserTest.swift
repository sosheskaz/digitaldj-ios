//
//  NewSessionTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/06/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
import DDJiOS
@testable import DDJiOS

class SrvNewUserTest: XCTestCase {
    var sessionId: String?
    
    override func setUp() {
        super.setUp()
        let nsCmd = ServerNewSessionCommand()
        let res = nsCmd.executeSync()
        guard let myData = res.data else {
            XCTFail("Failed to get session. Data was nil.")
            return
        }
        guard let sessionId = ServerNewSessionCommand.getValue(from: myData) else {
            print("SESSIONID: nil")
            XCTFail("Failed to get session. SessionId was not present in response. Response was: \n\(String(describing: String(data: myData, encoding: .utf8)))")
            return
        }
        self.sessionId = sessionId
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(self.sessionId != nil) {
            ServerEndSessionCommand(sessionId: self.sessionId!).execute()
        }
        self.sessionId = nil
    }
    
    func testNewUser() {
        guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }
        let testRegex = EZRegex(pattern: "^[\\da-f]{8}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{12}$", options: .caseInsensitive)
        let nuCmd = ServerNewUserCommand(tracks: ["6Fbsun5UAWFjeBpRatOITI", "06WPoSERagUDPT4DnjCK1S"], sessionId: sessionId)
        let res = nuCmd.executeSync()
        guard let myData = res.data else {
            XCTFail("data was nil.")
            return
        }
        guard let id = ServerNewUserCommand.getValue(from: myData) else {
            XCTFail("sessionId was not present in response. Response was: \n\(String(describing: String(data: myData, encoding: .utf8)))")
            return
        }
        if(testRegex == nil) {
            XCTFail("regex failed to init")
            return
        }
        let result = testRegex!.test(against: id)
        
        XCTAssert(result, "Result did not match regex. Actual: \(id)\nData: \(String(describing: String(data: myData, encoding: .utf8)))")
    }
    
    func testPerformanceNewUser() {
        self.measure {
            self.testNewUser()
        }
    }
    
}
