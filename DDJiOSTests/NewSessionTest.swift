//
//  NewSessionTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/27/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
import DDJiOS
@testable import DDJiOS

class NewSessionTest: XCTestCase {
    var cmd: ServerNewSessionCommand?
    var sessionIdsToCleanUp: [String] = []
    
    override func setUp() {
        super.setUp()
        cmd = ServerNewSessionCommand()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        for sessionId in sessionIdsToCleanUp {
            ServerEndSessionCommand(sessionId: sessionId).execute()
        }
    }
    
    func testNewSession() {
        var success = false
        let testRegex = EZRegex(pattern: "^[\\da-f]{8}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{4}-[\\da-f]{12}$", options: .caseInsensitive)
        cmd!.subscribe({data in
            guard let myData = data else {
                XCTFail("data was nil.")
                return
            }
            guard let sessionId = ServerNewSessionCommand.getSessionId(from: myData) else {
                XCTFail("sessionId was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
                return
            }
            if(testRegex == nil) {
                XCTFail("regex failed to init")
                return
            }
            let result = testRegex!.test(against: sessionIdStr)
            XCTAssert(result, "Result did not match regex.")
            success = true
        })
        cmd!.execute()
        sleep(3)
        XCTAssert(success)
    }
    
}
