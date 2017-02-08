//
//  DebugPrint.swift
//  DDJiOS
//
//  Created by Eric Miller on 2/7/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

func dprint(_ items: Any...) {
    #if DEBUG
        print("DEBUG: \(items)")
    #endif
}
