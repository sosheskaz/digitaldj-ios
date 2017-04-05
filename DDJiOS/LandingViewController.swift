//
//  LandingViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 12/12/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class LandingViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func LoginToSpotify(_ sender: Any) {
        MySpt.shared.login()
    }
    
    
    
}
