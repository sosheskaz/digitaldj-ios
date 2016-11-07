//
//  ServerSetupViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 11/6/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class ServerSetupViewController: UIViewController {
    @IBOutlet var nameField: UITextField? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as? ServerViewController;
        if(svc != nil) {
            svc?.passZcNameData(name: (nameField?.text)!)
        }
        super.prepare(for: segue, sender: sender)
    }
}
