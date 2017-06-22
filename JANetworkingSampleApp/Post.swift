//
//  Post.swift
//  RDV
//
//  Created by Eli Liebman on 8/8/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import JANetworking

public struct Post {
    
    public let id:String
    public var title:String
    public var body:String
    public let authorId:String

    
    /// Fetch a specific post from the server
    public static func postWithId(_ id:String) -> JANetworkingResource<Post> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        let params:JSONDictionary = ["post_id": id]
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: params, parseJSON: { json in
            guard let postDictionary = json as? JSONDictionary else { return nil }
            return Post(json: postDictionary)
        })
    }
    
    /// Fetch all posts
    public static func all() -> JANetworkingResource<[Post]> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let items = json as? [JSONDictionary] else { return nil }
            let posts = items.flatMap(Post.init)
            return posts
        })
    }
    
    /// Submit a post
    public func submit() -> JANetworkingResource<Post>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts")!
        let params:JSONDictionary = ["id": id,
                                     "author": authorId,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let postDictionary = json as? JSONDictionary else { return nil }
            return Post(json: postDictionary)
        })
    }
    
    /// Like a post
    public func like() -> JANetworkingResource<Bool> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/like/")!
        let params = ["post" : id]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let status = dictionary["StatusCode"] as? Int  else { return false }
            return status == 204
        })
    }
    
    /// Unlike a post
    public func unlike() -> JANetworkingResource<Bool> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/like/")!
        let params = ["post" : id]
        return JANetworkingResource(method: .DELETE, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let status = dictionary["StatusCode"] as? Int  else { return false }
            return status == 204
        })
    }
}


extension Post {

    // Define this function in an extension to not override the default initializer
    init?(json:JSONDictionary) {
        guard let id = json["id"] as? String,
            let title = json["title"] as? String,
            let body = json["body"] as? String,
            let authorId = json["author_id"] as? String else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.body = body
        self.authorId = authorId
    }
}
