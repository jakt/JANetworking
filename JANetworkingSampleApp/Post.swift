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

public enum PostType:String {
    case color = "Color"
    case image = "Image"
}


public enum PostFetchType:String {
    case here = "here"
    case now = "now"
    case hereAndNow = "hereandnow"
}

public class Post:NSObject {
    
    //get all posts with now filter
    public static func postOfType(_ type:PostFetchType, location:CLLocationCoordinate2D? = nil, radius:Int? = nil) -> JANetworkingResource<[Post]> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        var params:[String : Any]
        if let location = location, type != .now {
            params = ["filter": "here", "lat" : location.latitude, "lon" : location.longitude]
            if let radius = radius, type == .here {
                // RADIUS IS IN METERS. MAKE SURE TO CONVERT ACCORDINGLY BEFORE HANDING IN TO METHOD
                params["radius"] = radius
            }
        } else {
            params = ["filter": type.rawValue]
        }
        
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let items = dictionary["results"] as? [JSONDictionary] else { return nil }
            return []
        })
    }
    
    public static func all() -> JANetworkingResource<[Post]> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let items = dictionary["results"] as? [JSONDictionary] else { return [] }
            let posts:[Post] = []
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
