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
        
        // Add default headers
        for (key, value) in JANetworkingConfiguration.sharedConfiguration.configurationHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add the JSON Web Token if we have it
        if let token = JANetworkingConfiguration.token {
            request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
            // error is nil when request fails. Not nil when the request passes. However even if the request went through, the reponse can be of status code error 400 up or 500 up
            print("\n\(request.HTTPMethod) -- \(request.URL!.absoluteString)")
            if let errorObj = error {
                dispatch_async(dispatch_get_main_queue(),{
                    let networkError = JANetworkingError(error: errorObj)
                    completion(nil, error: networkError)
                })
            }else{
                dispatch_async(dispatch_get_main_queue(),{
                    // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data))
                    let results = data.flatMap(resource.parse)
                    completion(results, error: networkError)
                })
            }
            
        }.resume()
    }
    
    // Load image
    public static func loadImage(url: String, completion:(UIImage?, error: JANetworkingError?) -> ()){
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            if let errorObj = error {
                dispatch_async(dispatch_get_main_queue(),{
                    let networkError = JANetworkingError(error: errorObj)
                    completion(nil, error: networkError)
                })
            }else{
                dispatch_async(dispatch_get_main_queue(),{
                    // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data))
                    let image = UIImage(data: data!)
                    completion(image, error: networkError)
                })
            }
        }.resume()
    }
}

// ImageView Extension for convinience use

public extension UIImageView {
    func downloadImage(url: String, placeholder: UIImage? = nil){
        image = placeholder
        JANetworking.loadImage(url) { (image, error) in
            if let err = error {
                print("`JANetworking Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                print("`JANetworking Load.image` - ERROR: \(err.errorData)")
            }else{
                if let img = image {
                    self.image = img
                }
            }
        }
    }
}
