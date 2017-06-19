//
//  Post.swift
//  RDV
//
//  Created by Eli Liebman on 8/8/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import CoreData
import JANetworking
import CoreLocation

public class Post:NSObject {
    
    public var id:String
    public var title:String
    public var body:String
    public var authorId:String
    
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
    
    //get all posts with now filter
    public static func postWithId(_ id:String) -> JANetworkingResource<Post?> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        let params:JSONDictionary = ["post_id": id]
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let postDictionary = dictionary["results"] as? JSONDictionary else { return nil }
            return Post(json: postDictionary)
        })
    }
    
    public static func all() -> JANetworkingResource<[Post]?> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let items = dictionary["results"] as? [JSONDictionary] else { return nil }
            let posts = items.flatMap(Post.init)
            return posts
        })
    }
    
    //like
    public static func like(postID : String) -> JANetworkingResource<Bool> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/like/")!
        let params = ["post" : postID]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let status = dictionary["StatusCode"] as? Int  else { return false }
            return status == 204
        })
    }
    
    //unlike
    public static func unlike(postID : String) -> JANetworkingResource<Bool> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/like/")!
        let params = ["post" : postID]
        return JANetworkingResource(method: .DELETE, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let status = dictionary["StatusCode"] as? Int  else { return false }
            return status == 204
        })
    }
}
