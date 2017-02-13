//
//  DDJHostTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/5/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class DDJHostTest: XCTestCase {
    let shared = DDJHost.sharedTestable(timeoutSeconds: 20, checkSeconds: 5)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPutUser() {
        shared.putUser("sosheskaz", tracks: SPTManager.shared.tracks50, ipAddr: "127.0.0.1")
        let tracks = shared.playlist
        print(tracks)
        for track in tracks {
            // make sure the tracks we got are the ones we submitted!
            XCTAssertTrue(SPTManager.shared.tracks50.contains(track.identifier), "\(track.identifier) not found!")
        }
    }
}
