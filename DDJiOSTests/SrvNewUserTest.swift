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
        nsCmd.subscribe({ data in
            guard let myData = data else {
                XCTFail("Failed to get session. Data was nil.")
                return
            }
            guard let sessionId = ServerNewSessionCommand.getSessionId(from: myData) else {
                print("SESSIONID: nil")
                XCTFail("Failed to get session. SessionId was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            self.sessionId = sessionId
        })
        nsCmd.execute()
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
        sleep(3)
        guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }
        let testRegex = EZRegex(pattern: "^[\\da-f]{8}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{12}$", options: .caseInsensitive)
        var success = false
        let nuCmd = ServerNewUserCommand("sosheskaz", tracks: ["6Fbsun5UAWFjeBpRatOITI", "06WPoSERagUDPT4DnjCK1S"], sessionId: sessionId)
        nuCmd.subscribe({ data in
            guard let myData = data else {
                XCTFail("data was nil.")
                return
            }
            guard let id = ServerNewUserCommand.getUserId(from: myData) else {
                XCTFail("sessionId was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            if(testRegex == nil) {
                XCTFail("regex failed to init")
                return
            }
            let result = testRegex!.test(against: id)
            
            XCTAssert(result, "Result did not match regex. Actual: \(id)\nData: \(String(data: myData, encoding: .utf8))")
            success = true
        })
        nuCmd.execute()
        sleep(3)
        XCTAssert(success)
    }
    
}
