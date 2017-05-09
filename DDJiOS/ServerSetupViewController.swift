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
    private var defaults = UserDefaults.standard
    private static let defaultsNameLabel = "host_display_name"
    
    @IBOutlet var nameField: UITextField? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        if(defaults.object(forKey: ServerSetupViewController.defaultsNameLabel) == nil) {
            nameField?.placeholder = UIDevice.current.name
        } else {
            nameField?.text = defaults.object(forKey: ServerSetupViewController.defaultsNameLabel) as! String?
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let svc = segue.destination as? ServerViewController else {
            log.error("svc is not ServerViewController.")
            return
        }
        guard var name = nameField?.text else {
            log.error("Name field is empty.")
            return
        }
        log.verbose("Checking name is valid.")
        if(EZRegex(pattern: "^\\s*$")?.test(against: name) ?? true) {
            name = UIDevice.current.name
        }
        defaults.set(name, forKey: ServerSetupViewController.defaultsNameLabel)
        log.verbose("Passing name data.")
        svc.passZcNameData(name)
        log.verbose("Prepare complete.")
    }
}
