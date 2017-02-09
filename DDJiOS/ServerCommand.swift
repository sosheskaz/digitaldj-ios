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
    associatedtype T
    
    static var command: ServerCommandType {get}
    static var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var parameterEncoding: ParameterEncoding {get}
    var subscribers: [(Result<Data>?) -> Void] {get}

    func subscribe(_ listener: @escaping (Result<Data>?) -> Void)
    static func getValue(from data: Data?) -> T
}

extension ServerCommand {
    var parameterEncoding: ParameterEncoding {
        get {
            let dict: [HTTPMethod:ParameterEncoding] = [
                .get: URLEncoding.default,
                .post: JSONEncoding.default
            ]
            return dict[Self.method] ?? URLEncoding(destination: .methodDependent)
        }
    }
    
    func execute() {
        let endpoint = baseEndpoint + Self.command.rawValue
        let queue = DispatchQueue(label: "com.ddj.alamofire-queue", qos: .utility, attributes: [.concurrent])
        
        let req = Alamofire.request(endpoint, method: Self.method, parameters: self.parameters, encoding: self.parameterEncoding).validate().responseData(queue: queue, completionHandler: completionHandler)
        req.resume()
    }
    
    func executeSync() -> DataResponse<Data> {
        let endpoint = baseEndpoint + Self.command.rawValue
        let res = Alamofire.request(endpoint, method: Self.method, parameters: self.parameters, encoding: self.parameterEncoding).responseData()
        return res
    }
    
    private func completionHandler(response: DataResponse<Data>) {
        print("completion")
        for callback in self.subscribers {
            DispatchQueue.global().async {
                callback(response.result)
            }
        }
    }
    
    static func parseResponse(_ responseData: Data?) -> AnyObject? {
        guard let data = responseData else {
            print("nil")
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } catch {
            return String(data: data, encoding: .utf8) as AnyObject?
        }
    }
}

enum ServerCommandType: String {
    case heartbeat = "Geartbeat", newSession = "NewSession", endSession = "EndSession", newUser = "NewUser", removeUser = "RemoveUser", updateUser = "UpdateUser", getPlaylist = "GetPlaylist"
}


