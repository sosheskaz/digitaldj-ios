//
//  ZeroconfClientController.swift
//  DDJiOS
//
//  Created by Eric Miller on 10/31/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ZeroconfTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var zcTableView: UITableView? = nil
    
    var myTimer: Timer? = nil
    private var client: ZeroconfClient = ZeroconfClient()
    private var items: Array<NetService> = []
    private var selectedCell: Int = -1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.myTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
        items = Array<NetService>(client.getFoundServices())
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
        items = Array<NetService>(client.getFoundServices())
        self.zcTableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.row
        self.performSegue(withIdentifier: "ServerSelectSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RunLoop.main.add(self.myTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServerSelectSegue" {
            if let destination = segue.destination as? ClientViewController {
                destination.hostAddress = netServiceDidResolveAddress(items[selectedCell])!
                destination.hostName = items[selectedCell].hostName ?? ""
            }
        }
    }
    
    // http://stackoverflow.com/questions/38197198/swift-3-how-to-resolve-netservice-ip
    // ;_; what has my life become
    func netServiceDidResolveAddress(_ sender: NetService) -> String? {
        guard let addresses = sender.addresses else {
            print("addresses is nil!")
            return nil
        }
        guard addresses.count > 0 else {
            print("sender: ")
            print("no addresses!")
            return nil
        }
        guard let address = addresses.first else {
            print("no first address???")
            return nil
        }
        
        let data = NSData(data: address)
        
        let inetAddress: sockaddr_in = data.castToCPointer()
        if inetAddress.sin_family == __uint8_t(AF_INET) {
            if let ip = String(cString: inet_ntoa(inetAddress.sin_addr), encoding: .ascii) {
                // IPv4
                return ip
            }
        } else if inetAddress.sin_family == __uint8_t(AF_INET6) {
            let inetAddress6: sockaddr_in6 = data.castToCPointer()
            let ipStringBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
            var addr = inetAddress6.sin6_addr
            
            if let ipString = inet_ntop(Int32(inetAddress6.sin6_family), &addr, ipStringBuffer, __uint32_t(INET6_ADDRSTRLEN)) {
                if let ip = String(cString: ipString, encoding: .ascii) {
                    // IPv6
                    return ip
                }
            }
            
            ipStringBuffer.deallocate(capacity: Int(INET6_ADDRSTRLEN))
        }
        
        print("nil af")
        // shouldn't happen unless used incorrectly.
        return nil
    }
    
    struct ip_socket_address {
        let sa: sockaddr
        let ipv4: sockaddr_in
        let ipv6: sockaddr_in6
    }
}

extension NSData {
    func castToCPointer<T>() -> T {
        let mem = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
        self.getBytes(mem, length: MemoryLayout<T>.size)
        return mem.move()
    }
}
