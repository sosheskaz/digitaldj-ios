//
//  ClientViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientViewController: UIViewController {
    var hostAddress: String? = ""
    @IBOutlet weak var hostAddressLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hostAddressLabel.text = hostAddress!
    }
}
