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
    
    @IBAction func loginToSpotify(_ sender: Any) {
        MySpt.shared.login(callback: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "post-login-segue", sender: self)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MySpt.shared.loggedIn {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "logged-in-segue", sender: self)
            }
        }
    }
}
