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
    public static func postOfType(_ type:PostFetchType, location:CLLocation? = nil) -> JANetworkingResource<[Post]> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts/")!
        var params:[String : Any]
        if let location = location, type != .now {
            params = ["filter": "here", "lat" : location.coordinate.latitude, "lon" : location.coordinate.longitude]
        } else {
            params = ["filter": type.rawValue]
        }
        
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let items = dictionary["results"] as? [JSONDictionary] else { return nil }
            return nil
        })
    }
}
