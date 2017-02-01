//
//  HeartbeatCommandTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class HeartbeatTimeoutCommandTest: XCTestCase {
    var cmd: HeartbeatTimeoutCommand?
    let jsonObj = ["from":"127.0.0.1"]
    var sampleData: Data?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cmd = HeartbeatTimeoutCommand()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJson() {
        let data = cmd!.json
        XCTAssert(data != nil, "data was nil")
        
        var des: [String:AnyObject]? = nil
        do {
            des = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
        } catch {
            XCTAssert(false, "Deserialization failed.")
            return
        }
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["command"] as! String == "heartbeatTimeout", "Expected=heartbeatTimeout Actual=\(des!["command"])")
    }
    
}
