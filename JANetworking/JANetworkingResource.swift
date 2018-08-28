//
//  JANetworkingResource.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any?]

public enum RequestMethod: String {
    case POST = "POST"
    case PATCH = "PATCH"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}


/// Generic struct that is used to fetch resources from the server.
public struct JANetworkingResource<A>{
    public let id = UUID().uuidString
    public let method: RequestMethod
    public let url: URL
    public let headers: [String: String]?
    public let params: JSONDictionary?
    public let parse: (Data) -> A?
    public let parseJson: (Any) -> A?
}

extension JANetworkingResource {
    /// This is how all JANetworkingResource's should be created. Once configured, the resource is handed into the JANetworking loadJSON function
    /// parseJSON is where the server data is converted into actual objects.
    public init(method: RequestMethod, url: URL, headers: [String: String]?, params: JSONDictionary?, parseJSON: @escaping (Any) -> A?){
        self.method = method
        self.url = url
        self.headers = headers
        self.params = params
        self.parseJson = parseJSON
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
