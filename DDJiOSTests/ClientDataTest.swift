//
//  ClientDataTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/20/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

private let sampleUserTokens: Array<String> = ["User Token 1", "User Token 2", "User Token 3", "User Token 4", "User Token 5"].sorted()
private let deserializableString: String = "{\"userToken\": \"\(sampleUserTokens[0])\"}"

class ClientDataTest: XCTestCase {
    var data: ClientData? = ClientData()
    
    override func setUp() {
        super.setUp()
        self.data = ClientData()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitFromJson() {
        self.data = ClientData(fromJson: deserializableString)
        XCTAssert(self.data != nil)
        XCTAssert(self.data!.getUserToken() == sampleUserTokens[0])
    }
    
    func testToJson() {
        self.data = ClientData(fromJson: deserializableString)
        let result: String = self.data!.toJson()!
        self.data = ClientData(fromJson: result)
        XCTAssert(self.data != nil, "Failed to init from JSON: \(result)")
        XCTAssert(self.data!.getUserToken() != nil, "Failed to init from JSON: \(result)")
        
        XCTAssert(self.data!.getUserToken() == sampleUserTokens[0], "expected \(sampleUserTokens[0]), got \(self.data!.getUserToken()!)")
    }
    
    func testUserTokenGetSet() {
        XCTAssert(self.data!.userToken == nil)
        self.data!.setUserToken(sampleUserTokens[2])
        XCTAssert(self.data!.getUserToken() == sampleUserTokens[2])
    }
}
