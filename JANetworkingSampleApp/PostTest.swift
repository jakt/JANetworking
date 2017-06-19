//
//  PostTest.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation
import JANetworking

struct PostTest {
    let id: Int
    let userName: String
    var title: String
    var body: String
}

extension PostTest {
    init?(dictionary: JSONDictionary){
        guard let id = dictionary["id"] as? Int,
            let title = dictionary["title"] as? String,
            let userName = dictionary["user_name"] as? String,
            let body = dictionary["body"] as? String else { return nil }
        
        self.id = id
        self.userName = userName
        self.title = title
        self.body = body
    }
    
    
    // Get all post
    static func all(headers: [String: String]?) -> JANetworkingResource<[PostTest]>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts")!
        return JANetworkingResource(method: .GET, url: url, headers: headers, params: ["test":["test2":"test3"]], parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let result = dictionary["results"] as? [JSONDictionary] else { return nil }
            return result.flatMap(PostTest.init)
        })
    }
    
    // Submit a post
    func submit(headers: [String: String]?) -> JANetworkingResource<PostTest>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts")!
        let params:JSONDictionary = ["id": id,
                                     "userName": userName,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .POST, url: url, headers: headers, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return PostTest(dictionary: dictionary)
        })
    }
    
    // Update a post
    func update(headers: [String: String]?) -> JANetworkingResource<PostTest>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/\(id)")!
        let params:JSONDictionary = ["id": id,
                                     "userName": userName,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .PUT, url: url, headers: headers, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return PostTest(dictionary: dictionary)
        })
    }
}
