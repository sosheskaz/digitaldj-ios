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
    private let sampleQueue = SPTManager.shared.tracks50
    private let shortQueue: [String] = Array(SPTManager.shared.tracks50[1...49])
    let listener = ClientCommandListener.shared
    
    override func setUp() {
        super.setUp()
        _ = listener.on()
        usleep(10000)
    }
    
    override func tearDown() {
        super.tearDown()
        listener.off()
    }
    
    func testInitCurrentlyPlayingAndQueue() {
        let cmd: UpdatePlaylistCommand = UpdatePlaylistCommand(
            currentlyPlaying: sampleQueue[0],
            queue: shortQueue)
        XCTAssert(cmd.currentlyPlaying == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(String(describing: cmd.currentlyPlaying))")
        XCTAssert(cmd.queue.elementsEqual(shortQueue), "Queue: Expected=\(shortQueue) Actual=\(cmd.queue)")
    }
    
    func testInitFullQueue() {
        let cmd: UpdatePlaylistCommand = UpdatePlaylistCommand(fullQueue: sampleQueue)
        XCTAssert(cmd.currentlyPlaying == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(String(describing: cmd.currentlyPlaying))")
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
        
        XCTAssert(des!["command"] as! String == "updatePlaylist", "Expected=updatePlaylist Actual=\(String(describing: des!["command"]))")
        XCTAssert(des != nil, "deserialization downcast failed.")
        XCTAssert(des!["currentlyPlaying"] as! String == sampleQueue[0],
                  "Currently Playing: Expected=\(sampleQueue[0]) Actual=\(String(describing: cmd.currentlyPlaying))")
        XCTAssert((des!["queue"] as! [String]).elementsEqual(shortQueue), "Queue: Expected=\(shortQueue) Actual=\(cmd.queue)")
    }
    
    func testSend() {
        let cmd = UpdatePlaylistCommand(fullQueue: sampleQueue)
        
        class Delegate: ClientCommandListenerDelegate {
            var didComplete = false
            var elements: [String] = []
            
            func clientCommandListener(heartbeat: HeartbeatCommand) {
                
            }
            func clientCommandListener(heartbeatTimeout: HeartbeatTimeoutCommand) {
                
            }
            func clientCommandListener(updatePlaylist: UpdatePlaylistCommand) {
                self.didComplete = true
                self.elements = [updatePlaylist.currentlyPlaying!] + updatePlaylist.queue
            }
        }
        let d = Delegate()
        listener.delegate = d
        
        let exRes = cmd.execute("127.0.0.1")
        sleep(1)
        
        XCTAssert(exRes)
        XCTAssert(d.didComplete)
        XCTAssert(d.elements.elementsEqual(sampleQueue))
    }
}
