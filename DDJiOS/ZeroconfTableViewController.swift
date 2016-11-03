//
//  ZeroconfClientController.swift
//  DDJiOS
//
//  Created by Eric Miller on 10/31/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit

class ZeroconfTableViewController: UITableViewController {
    private var client: ZeroconfClient
    private var items: Array<String> = ["a", "b", "c"]
    private var selected: Int
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    override func loadView() {
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }

}
