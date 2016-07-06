//
//  Post.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation
import JANetworking

let baseUrl = "http://demo3646012.mockable.io"

struct Post {
    let id: Int
    let userName: String
    let title: String
    let body: String
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
    
    static let postUrl = NSURL(string: baseUrl + "/posts")!
    
    // Get all post
    static let headers = ["Authorization":"myTokenValue"]
    static let all = JANetworkingResource<[Post]>(method: .GET, url: postUrl, headers: headers, params: nil, parseJSON: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Post.init)
    })
    
    // Submit a post
    static let params = ["title": "I am Cool",
                         "body": "Some text goes here yes",
                         "user_name": "Matt"]
    static let submit = JANetworkingResource<Post>(method: .POST, url: postUrl, headers: nil, params: params, parseJSON: { json in
        guard let dictionary = json as? JSONDictionary else { return nil }
        return Post(dictionary: dictionary)
    })
}
