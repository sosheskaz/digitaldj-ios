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
        self.sessionId = ServerNewSessionCommand.getValue(from: nsCmd.executeSync().data)
        print("New Session: \(String(describing: ServerNewSessionCommand.getValue(from: nsCmd.executeSync().data)))")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(sessionId != nil) {
            _ = ServerEndSessionCommand(sessionId: self.sessionId!).executeSync()
            sessionId = nil
        }
    }
    
    func testEndSession() {
        guard let sessionId = self.sessionId else {
            XCTFail("sessionId was nil; setup failed.")
            return
        }
        let esCmd = ServerEndSessionCommand(sessionId: sessionId)
        let success = ServerEndSessionCommand.getValue(from: esCmd.executeSync().data)
        self.sessionId = nil
        XCTAssert(success)
    }
    
    func testEndSessionFailure() {
        let sessionId = "not-a-real-id"
        let esCmd = ServerEndSessionCommand(sessionId: sessionId)
        let success = !ServerEndSessionCommand.getValue(from: esCmd.executeSync().data)
        XCTAssert(success)
        self.sessionId = nil
    }
    
    func testPerformanceNewSessionEndSessionRoundTrip() {
        if(self.sessionId != nil) {
            let didEnd = ServerEndSessionCommand.getValue(from: ServerEndSessionCommand(sessionId: self.sessionId!).executeSync().data)
            XCTAssert(didEnd)
            self.sessionId = nil
        }
        
        measure {
            let sessionId = ServerNewSessionCommand.getValue(from: ServerNewSessionCommand().executeSync().data)!
            let didEnd = ServerEndSessionCommand.getValue(from: ServerEndSessionCommand(sessionId: sessionId).executeSync().data)
            XCTAssert(didEnd)
        }
    }
}
