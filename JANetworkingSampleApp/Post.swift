//
//  Post.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation
import JANetworking

struct Post {
    let id: Int
    let userName: String
    var title: String
    var body: String
}

extension Post {
    init?(dictionary: [String: AnyObject]){
        guard let id = dictionary["id"] as? Int,
            title = dictionary["title"] as? String,
            userName = dictionary["user_name"] as? String,
            body = dictionary["body"] as? String else { return nil }
        
        self.id = id
        self.userName = userName
        self.title = title
        self.body = body
    }
    
    
    // Get all post
    static func all(headers: [String: String]?) -> JANetworkingResource<[Post]>{
        let url = NSURL(string: baseUrl + "/posts")!
        return JANetworkingResource(method: .GET, url: url, headers: headers, params: ["test":"test"], parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, result = dictionary["results"] as? [JSONDictionary] else { return nil }
            return result.flatMap(Post.init)
        })
    }
    
    // Submit a post
    func submit(headers: [String: String]?) -> JANetworkingResource<Post>{
        let url = NSURL(string: baseUrl + "/posts")!
        let params:JSONDictionary = ["id": id,
                                     "userName": userName,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .POST, url: url, headers: headers, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return Post(dictionary: dictionary)
        })
    }
    
    // Update a post
    func update(headers: [String: String]?) -> JANetworkingResource<Post>{
        let url = NSURL(string: baseUrl + "/posts/\(id)")!
        let params:JSONDictionary = ["id": id,
                                     "userName": userName,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .PUT, url: url, headers: headers, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return Post(dictionary: dictionary)
        })
    }
}
