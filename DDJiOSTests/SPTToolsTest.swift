//
//  SPTToolsTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/12/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class SPTToolsTest: XCTestCase {
    

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTracksFromIds() {
        guard let tracks = DDJSPTTools.SPTTracksFromIdsOrUris(SPTManager.shared.tracks50) else {
            XCTFail("Failed.")
            return
        }
        XCTAssertEqual(SPTManager.shared.tracks50.count, tracks.count)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            _ = DDJSPTTools.SPTTracksFromIdsOrUris(SPTManager.shared.tracks50)
        }
    }
    
}
