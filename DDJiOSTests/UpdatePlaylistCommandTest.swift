//
//  UpdatePlaylistCommandTest.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/14/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import XCTest
@testable import DDJiOS

class UpdatePlaylistCommandTest: XCTestCase {
    private let sampleQueue = ["a", "b", "c", "d", "e"]
    private let shortQueue = ["b", "c", "d", "e"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitCurrentlyPlayingAndQueue() {
        let cmd: UpdatePlaylistCommand = UpdatePlaylistCommand(
            currentlyPlaying: sampleQueue[0],
            queue: shortQueue)
        XCTAssert(cmd.currentlyPlaying == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(cmd.currentlyPlaying)")
        XCTAssert(cmd.queue.elementsEqual(shortQueue), "Queue: Expected=\(shortQueue) Actual=\(cmd.queue)")
    }
    
    func testInitFullQueue() {
        let cmd: UpdatePlaylistCommand = UpdatePlaylistCommand(fullQueue: sampleQueue)
        XCTAssert(cmd.currentlyPlaying == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(cmd.currentlyPlaying)")
        XCTAssert(cmd.queue.elementsEqual(shortQueue), "Queue: Expected=\(shortQueue) Actual=\(cmd.queue)")
    }
    
    func testJson() {
        let cmd: UpdatePlaylistCommand = UpdatePlaylistCommand(fullQueue: sampleQueue)
        let data = cmd.json
        XCTAssert(data != nil, "data was nil")
        
        var des: [String:AnyObject]? = nil
        do {
            des = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
        } catch {
            XCTAssert(false, "Deserialization failed.")
            return
        }
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["currentlyPlaying"] as! String == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(cmd.currentlyPlaying)")
        XCTAssert((des!["queue"] as! [String]).elementsEqual(shortQueue), "Queue: Expected=\(shortQueue) Actual=\(cmd.queue)")
    }
}
