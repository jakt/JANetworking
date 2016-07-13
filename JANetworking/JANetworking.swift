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
                let networkError = JANetworkingError(error: errorObj)
                completion(nil, error: networkError)
            }else{
                // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                // Ensure that there is no error in the reponse and in the server
                let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data))
                let results = data.flatMap(resource.parse)
                completion(results, error: networkError)
            }
            
        }.resume()
    }
    
    // Upload image
//    // Add the image
//    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", FileParamConstant, assignmentTitle] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Type:image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:imageData];
//    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    // Add the string - Its important to make sure the name is set to the correct value. In this example the name of the parameter is "string"
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"assignment\"\r\n\r\n%@", [NSString stringWithFormat:@"%@/assignments/%@/", AIApiEndpoint, assignmentId]] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    public static func uploadImageWithParameters<A>(image: UIImage, params: [String: String], completion:(A?, error: JANetworkingError?) -> ()){
//        
//    }
    
    
    
    
}
