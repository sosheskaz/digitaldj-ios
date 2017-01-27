//
//  EZRegex.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/27/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class EZRegex {
    private let internalRegex: NSRegularExpression
    
    init?(pattern: String, options: NSRegularExpression.Options) {
        do {
            internalRegex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return nil
        }
    }
    
    convenience init?(pattern: String) {
        self.init(pattern: pattern, options: [])
    }
    
    func test(against string: String) -> Bool {
        return self.test(against: string, options: [])
    }
    
    func test(against string: String, options: NSRegularExpression.MatchingOptions) -> Bool {
        return internalRegex.firstMatch(in: string, options: options, range: NSRange(location: 0, length: string.characters.count)) != nil
    }
    
    func matches(against string: String) -> [NSTextCheckingResult] {
        return matches(against: string, options: [])
    }
    
    func matches(against string: String, options: NSRegularExpression.MatchingOptions) -> [NSTextCheckingResult] {
        return internalRegex.matches(in: string, options: options, range: NSRange(location: 0, length: string.characters.count))
    }
    
    var nsRegex: NSRegularExpression {
        get {
            return internalRegex
        }
    }
}
