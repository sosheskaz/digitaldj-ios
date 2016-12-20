//
//  ServerDataTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/19/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

let sampleUserTokens: Array<String> = ["User Token 1", "User Token 2", "User Token 3", "User Token 4", "User Token 5"].sorted()
let deserializableString: String = "{\"userTokens\": [ \"User Token 1\", \"User Token 2\", \"User Token 3\", \"User Token 4\", \"User Token 5\"]}"

class ServerDataTest: XCTestCase {
    var data: ServerData = ServerData()
    
    override func setUp() {
        super.setUp()
        
        data = ServerData()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddTokens() {
        for token in sampleUserTokens {
            data.addUserToken(token: token)
        }
        
        var resultingTokens = data.getUserTokens().sorted()
        
        for i in 0...(sampleUserTokens.count - 1) {
            XCTAssert(sampleUserTokens[i] == resultingTokens[i])
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRemoveTokens() {
        data = ServerData(userTokens: sampleUserTokens)
        
        data.removeUserToken(token: sampleUserTokens[0])
        data.removeUserToken(token: sampleUserTokens[3])
        data.removeUserToken(token: sampleUserTokens[4])
        
        let resultingTokens = data.getUserTokens().sorted()
        
        XCTAssert(resultingTokens.contains(sampleUserTokens[1]))
        XCTAssert(resultingTokens.contains(sampleUserTokens[2]))
        XCTAssert(!resultingTokens.contains(sampleUserTokens[0]))
        XCTAssert(!resultingTokens.contains(sampleUserTokens[3]))
        XCTAssert(!resultingTokens.contains(sampleUserTokens[4]))
        XCTAssert(resultingTokens.count == sampleUserTokens.count - 3)
    }
    
    func testSerialize() {
        data = ServerData(userTokens: sampleUserTokens)
        let json = data.toJson()!
        
        data = ServerData()
        data.fill(fromJson: json)
        
        let resultingTokens = data.getUserTokens().sorted()
        for i in 0...(sampleUserTokens.count - 1) {
            XCTAssert(sampleUserTokens[i] == resultingTokens[i])
        }
    }
    
    func testDeserialize() {
        do {
            data = ServerData()
            data.fill(fromJson: deserializableString)
            
            let resultingTokens = data.getUserTokens().sorted()
            XCTAssert(resultingTokens.count == 5)
            for i in 0...(sampleUserTokens.count - 1) {
                XCTAssert(sampleUserTokens[i] == resultingTokens[i])
            }
            
        } catch {
            XCTAssert(false)
        }
    }
}
