//
//  ServerCommand.swift
//  DDJiOS
//
//  Created by Eric Miller on 1/27/17.
//  Copyright © 2017 msoe. All rights reserved.
//

import Foundation
import Alamofire

private let baseEndpoint = "http://digitaldj.us-west-2.elasticbeanstalk.com/api/v1/"

protocol ServerCommand {
    static var command: ServerCommandType {get}
    static var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var subscribers: [(Data?) -> Void] {get}

    func subscribe(_ listener: @escaping (Data?) -> Void)
}

extension ServerCommand {
    func execute() {
        let endpoint = baseEndpoint + Self.command.rawValue
        let queue = DispatchQueue(label: "com.ddj.alamofire-queue", qos: .utility, attributes: [.concurrent])
        // this automatically uses HTTP Body if appropriate.
        Alamofire.request(endpoint, method: Self.method, parameters: self.parameters).validate().responseData(queue: queue, completionHandler: completionHandler).resume()
    }
    
    private func completionHandler(response: DataResponse<Data>) {
        print("completion")
        for callback in self.subscribers {
            DispatchQueue.global().async {
                callback(response.data)
            }
        }
    }
}

enum ServerCommandType: String {
    case heartbeat = "Geartbeat", newSession = "NewSession", endSession = "EndSession", newUser = "NewUser", removeUser = "RemoveUser", updateUser = "UpdateUser", getPlaylist = "GetPlaylist"
}


