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
        if let params = resource.params as? [String:String]{
            if resource.method == .GET { 
                let query = buildQueryString(fromDictionary: params)
                let baseURL = request.URL!.absoluteString
                request.URL = NSURL(string: baseURL + query)
            } else {
                if let jsonParams = try? NSJSONSerialization.dataWithJSONObject(params, options: []) {
                    request.HTTPBody = jsonParams
                }
            }
           
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
    public static func loadImage(url: String, completion:(image:UIImage?, error: JANetworkingError?) -> ()){
        let imageURL = locationForImageAtURL(url)
        let checkImage = NSFileManager.defaultManager()
        // Check local disk for image 
        if let imageURL = imageURL where checkImage.fileExistsAtPath(imageURL) && JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let image = UIImage(contentsOfFile: imageURL)
                dispatch_async(dispatch_get_main_queue(),{
                    completion(image: image, error: nil)
                })
            }
        } else {
             NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
                if let errorObj = error {
                    dispatch_async(dispatch_get_main_queue(),{
                        let networkError = JANetworkingError(error: errorObj)
                        completion(image: nil, error: networkError)
                    })
                }else{
                    var image:UIImage?
                    // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data))
                    
                    if let imageData = data {
                        image = UIImage(data: imageData)
                        let imageDirectory = imageDirectoryPath
                        if let imageURL = imageURL where image != nil && JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
                            do {
                                // add directory if it doesn't exist
                                if !imageDirectory.checkResourceIsReachableAndReturnError(nil) {
                                    try NSFileManager.defaultManager().createDirectoryAtURL(imageDirectory, withIntermediateDirectories: true, attributes: nil)
                                }
                                // save file
                                try imageData.writeToFile(imageURL, options: .DataWritingAtomic)
                            } catch let fileError {
                                print(fileError)
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        completion(image: image, error: networkError)
                    })
                }
                }.resume()
            }
    }
    
    public static func removeImageAtUrl(url:String) -> Bool {
        if let imageURL = locationForImageAtURL(url) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imageURL)
                return true
            } catch let fileError{
                print(fileError)
            }
        } else {
            // Could no parse image url
            return false
        }
        
        return false
    }
    
    public static func removeAllCachedImages() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageDirectoryPath)
            return true
        } catch let fileError {
            print(fileError)
        }
        return false
    }
    
    private static func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        for (k, value) in parameters {
            if let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        return urlVars.isEmpty ? "" : "?" + urlVars.joinWithSeparator("&")
    }
    
    private static func locationForImageAtURL(url:String) -> String? {
        let imageDirectory = imageDirectoryPath
        var saveName = url
        saveName = saveName.stringByReplacingOccurrencesOfString("/", withString: "")
        let imageURL = imageDirectory.URLByAppendingPathComponent("\(saveName)").path
        
        return imageURL
    }
    
    private static var imageDirectoryPath:NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let imageDirectory = documentsURL.URLByAppendingPathComponent("image_cache")
        return imageDirectory
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
