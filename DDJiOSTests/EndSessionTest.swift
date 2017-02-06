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

class EndSessionTest: XCTestCase {
    var sessionId: String?
    
    override func setUp() {
        super.setUp()
        let nsCmd = ServerNewSessionCommand()
        nsCmd.subscribe({ data in
            guard let myData = data else {
                XCTFail("Failed to get session. Data was nil.")
                return
            }
            guard let responseData = ServerNewSessionCommand.parseResponse(myData) else {
                XCTFail("Failed to get session. ResponseData was nil. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            guard let sessionId = responseData["sessionId"] else {
                XCTFail("Failed to get session. SessionId was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            guard let sessionIdStr = sessionId as? String else {
                XCTFail("Failed to get session. SessionId was not a string. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            self.sessionId = sessionIdStr
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(sessionId != nil) {
            ServerEndSessionCommand(sessionId: self.sessionId!).execute()
        }
    }
    
    func testEndSession() {
        guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }
        var success = false
        let esCmd = ServerEndSessionCommand(sessionId: sessionId)
        esCmd.subscribe({ data in
            guard let myData = data else {
                XCTFail("data was nil.")
                return
            }
            guard let responseData = ServerEndSessionCommand.parseResponse(myData) else {
                XCTFail("responseData was nil. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            guard let reqWasSuccess = responseData["success"] else {
                XCTFail("success was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            guard let reqWasSuccessBool = reqWasSuccess as? Bool else {
                XCTFail("success was not a boolean. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            success = reqWasSuccessBool
        })
        esCmd.execute()
        sleep(6)
        XCTAssert(success)
    }
    
}
