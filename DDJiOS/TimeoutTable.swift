//
//  TimeoutTable.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class TimeoutTable {
    static var sharedTimeoutTable = TimeoutTable()
    
    var timeouts: [String: Entry] = [:]
    var timeToLiveSeconds: Int = 15 * 60
    var refreshRateSeconds: UInt32 = 60
    
    private var now: Date {
        get{
            return Date()
        }
    }
    
    private init() {
        DispatchQueue.global().async {
            while(true) {
                self.purgeOld()
                sleep(self.refreshRateSeconds)
            }
        }
    }
    
    func handleHeartbeat(from cmd: HeartbeatAckCommand) {
        guard let address = cmd.address else {
            return
        }
        
        timeouts[cmd.userId!] = Entry(lastContact: now, address: address)
    }
    
    func purgeOld() {
        for (userId, entry) in timeouts {
            let lastContact = entry.lastContact
            let timeSinceLastContact =  now.seconds(from: lastContact)
            if(timeSinceLastContact >= timeToLiveSeconds) {
                timeouts.removeValue(forKey: userId)
            }
        }
    }
    
    func purgeTable() {
        timeouts.removeAll()
    }
    
    subscript(index: String) -> Entry? {
        get {
            return timeouts[index]
        }
        set(value) {
            guard let entry = value else {
                return
            }
            timeouts[index] = entry
        }
    }
    
    struct Entry {
        var lastContact: Date
        var address: String
    }
}

// Fuck you, NSDate.
// https://stackoverflow.com/questions/27182023/getting-the-difference-between-two-nsdates-in-months-days-hours-minutes-seconds
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
