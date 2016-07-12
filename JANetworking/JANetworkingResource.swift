//
//  JANetworkingResource.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: AnyObject]

public enum RequestMethod: String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public struct JANetworkingResource<A>{
    public let method: RequestMethod
    public let url: NSURL
    public let headers: [String: String]?
    public let params: JSONDictionary?
    public let parse: NSData -> A?
}

extension JANetworkingResource {
    public init(method: RequestMethod, url: NSURL, headers: [String: String]?, params: JSONDictionary?, parseJSON: AnyObject -> A?){
        self.method = method
        self.url = url
        self.headers = headers
        self.params = params
        self.parse = { data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            // Check for a JSON Web Token
            if let parsedData = json as? JSONDictionary, token = parsedData["token"] as? String {
                print("Token: \(token)")
                JANetworkingConfiguration.token = token
            }
            
            return json.flatMap(parseJSON)
        }
    }
}