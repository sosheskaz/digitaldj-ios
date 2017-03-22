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
            return
        }
        guard var name = nameField?.text else {
            return
        }
        if(EZRegex(pattern: "^\\s*$")?.test(against: name) ?? true) {
            name = UIDevice.current.name
        }
        defaults.set(name, forKey: ServerSetupViewController.defaultsNameLabel)
        svc.passZcNameData(name)
    }
}
