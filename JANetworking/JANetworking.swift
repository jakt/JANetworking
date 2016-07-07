//
//  JANetworking.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public final class JANetworking {
    // Load json request
    public static func loadJSON<A>(resource: JANetworkingResource<A>, completion:(A?, error: JANetworkingError?) -> ()){
        let request = NSMutableURLRequest(URL: resource.url)
        request.HTTPMethod = resource.method.rawValue
        
        // Setup headers
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let headers = resource.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Setup params
        if let params = resource.params, jsonParams = try? NSJSONSerialization.dataWithJSONObject(params, options: []) {
            request.HTTPBody = jsonParams
        }
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // error is nil when failed request. Not nil when the request went through. However even if the request went through, the reponse can be of status code error 400 up or 500 up
            if let errorObj = error {
                let networkError = JANetworkingError(error: errorObj)
                completion(nil, error: networkError)
            }else{
                // Success request, HOWEVER the reponse can be with status code 400 and up
                let result = data.flatMap(resource.parse)
                let networkError = JANetworkingError(response: response)
                completion(result, error: networkError)
            }
            
        }.resume()
    }
}
