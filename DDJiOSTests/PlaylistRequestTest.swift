//
//  PlaylistRequestTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/8/17.
//  Copyright © 2017 msoe. All rights reserved.
//

@testable import DDJiOS
import XCTest

class PlaylistRequestTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMethod() {
        let aToken = "BQCkYhOqS0EkFaFu9fHnKNJr_tFvg-9epQb0i3hLeQ7tuqdH_5EHyWIcpVZBRZBUtvk5024kBXmrmQF6X_NCyGwn5cFe7ZmvTOZ3T0Orm6jOahk9fWMrqNgvJoa_6tgguPHtzGI2kvdZNGIxZg3E62lV6t4CYC9pa6rRznfvNsJPVdppKRH0cdne7l4L8g"
        let req = DDJSPlaylistRequest(oauthTokens: [aToken])
        var success = false
        req.doRequest(callback: { data in
            print("done")
            success = true
        })
        sleep(3)
        print(success)
    }
    
}
