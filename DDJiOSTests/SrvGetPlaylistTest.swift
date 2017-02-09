//
//  SrvGetPlaylistTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/8/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class SrvGetPlaylistTest: XCTestCase {
    private var sessionId: String?
    
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
            XCTFail("Failed to get session. SessionId was not present in response. Response was: \n\(String(data: myData, encoding: .utf8))")
            return
        }
        self.sessionId = sessionId
        
        
        let nuCmd = ServerNewUserCommand(tracks: ["6Fbsun5UAWFjeBpRatOITI", "06WPoSERagUDPT4DnjCK1S"], sessionId: sessionId)
        for _ in 0...10 {
            _ = nuCmd.executeSync()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if(self.sessionId != nil) {
            let esCmd = ServerEndSessionCommand(sessionId: self.sessionId!)
            _ = esCmd.executeSync()
        }
    }
    
    func testGetPlaylist() {
        guard let session = self.sessionId else {
            XCTFail("self.sessionId was nil.")
            return
        }
        
        let gpCmd = ServerGetPlaylistCommand(sessionId: session, numTracksToGet: 10)
        let res = gpCmd.executeSync()
        guard let data = res.data else {
            XCTFail("Didn't get data back. \(res.error!)")
            return
        }
        let arr = ServerGetPlaylistCommand.getValue(from: data)
        XCTAssert(arr.count > 0, "size of return was < 1. Actual: \(arr.count)")
    }
    
    func testPerformanceGetPlaylist() {
        guard let session = self.sessionId else {
            XCTFail("self.sessionId was nil.")
            return
        }
        
        let gpCmd = ServerGetPlaylistCommand(sessionId: session, numTracksToGet: 10)
        self.measure {
            _ = gpCmd.executeSync()
        }
    }
}
