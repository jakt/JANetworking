//
//  JANetworkingResource.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]

public enum RequestMethod: String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public struct JANetworkingResource<A>{
    public let id = UUID().uuidString
    public let method: RequestMethod
    public let url: URL
    public let headers: [String: String]?
    public let params: JSONDictionary?
    public let parse: (Data) -> A?
}

extension JANetworkingResource {
    public init(method: RequestMethod, url: URL, headers: [String: String]?, params: JSONDictionary?, parseJSON: @escaping (Any) -> A?){
        self.method = method
        self.url = url
        self.headers = headers
        self.params = params
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            // Check for a JSON Web Token
            if let parsedData = json as? JSONDictionary, let token = parsedData["token"] as? String {
                JANetworkingConfiguration.token = token
            }
            
            return json.flatMap(parseJSON)
        }
    }
}
