//
//  ClientViewController.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/16/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation

class ClientViewController: UIViewController {
    private let client: DDJClient = DDJClient.shared
    var hostAddress: String? = ""
    @IBOutlet weak var hostAddressLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        client.connect(to: hostAddress!)
        
        super.viewWillAppear(animated)
        self.hostAddressLabel.text = hostAddress!
    }
}
