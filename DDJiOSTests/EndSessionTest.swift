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
            guard let myData = data?.value else {
                print("Failed to get session. Data was nil.")
                print("Error: \(data?.debugDescription)")
                return
            }
            guard let sessionId = ServerNewSessionCommand.getValue(from: myData) else {
                print("Failed to get session. ResponseData was nil. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            self.sessionId = sessionId
        })
        nsCmd.execute()
        sleep(3)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(sessionId != nil) {
            ServerEndSessionCommand(sessionId: self.sessionId!).execute()
        }
    }
    
    func testEndSession() {
        /*guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }*/
        let sessionId = self.sessionId ?? "id"
        var success = false
        let esCmd = ServerEndSessionCommand(sessionId: sessionId)
        esCmd.subscribe({ data in
            guard let myData = data?.value else {
                print("Error: \(data?.debugDescription)")
                XCTFail("data was nil.")
                return
            }
            let reqWasSuccess = ServerEndSessionCommand.getValue(from: myData)
            if(reqWasSuccess) {
                self.sessionId = nil
            }
            XCTAssert(reqWasSuccess, "response was failure. Response was: \n\(String(data: myData, encoding: .utf8))")
            success = reqWasSuccess
        })
        esCmd.execute()
        sleep(3)
        XCTAssert(success)
    }
    
    func testEndSessionFailure() {
        let sessionId = "not-a-real-id"
        var success = false
        let esCmd = ServerEndSessionCommand(sessionId: sessionId)
        esCmd.subscribe({ data in
            guard let myData = data?.value else {
                print("Error: \(data?.debugDescription)")
                XCTFail("data was nil.")
                return
            }
            let reqWasSuccess = ServerEndSessionCommand.getValue(from: myData)
            XCTAssert(!reqWasSuccess, "response was success. Should have failed.. Response was: \n\(String(data: myData, encoding: .utf8))")
            success = !reqWasSuccess
        })
        esCmd.execute()
        sleep(3)
        XCTAssert(success)
    }
    
}
