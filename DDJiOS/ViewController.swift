//
//  ViewController.swift
//  DDJiOS
//
//  Created by Miguel Marquez on 10/26/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let zc: ZeroconfServer = ZeroconfServer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        zc.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

