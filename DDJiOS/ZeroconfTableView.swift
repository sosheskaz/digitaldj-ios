//
//  ZeroconfClientController.swift
//  DDJiOS
//
//  Created by Eric Miller on 10/31/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class ZeroconfTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var zcTableView: UITableView? = nil
    
    var myTimer: Timer? = nil
    private var client: ZeroconfClient = ZeroconfClient()
    private var items: Array<NetService> = []
    private var selected: Int = -1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.myTimer = Timer(timeInterval: 2.5, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
        items = client.getFoundServices()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // https://www.weheartswift.com/how-to-make-a-simple-table-view-with-ios-8-and-swift/
        
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func refresh() {
        print("refresh")
        items = client.getFoundServices()
        print(items)
        self.zcTableView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RunLoop.main.add(self.myTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }

}
