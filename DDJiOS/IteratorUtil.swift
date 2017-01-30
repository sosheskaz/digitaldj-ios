//
//  IteratorUtil.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/30/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

extension Sequence {
    func take(_ n: Int) -> [Self.Iterator.Element] {
        var itr = self.makeIterator()
        var i = 0
        
        var arr: [Self.Iterator.Element] = []
        
        while(i < n) {
            arr.append(itr.next()!)
            i += 1
        }
        
        return arr
    }
}
