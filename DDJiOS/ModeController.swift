//
//  ModeController.swift
//  DDJiOS
//
//  Created by Eric Miller on 5/4/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ModeController: UITabBarController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MySpt.shared.login()
    }
}
