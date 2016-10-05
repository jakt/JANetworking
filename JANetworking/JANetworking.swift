//
//  JANetworking.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public enum MediaType {
    case image
    case gif
}

public final class JANetworking {
    // Load json request
    public static func loadJSON<A>(resource: JANetworkingResource<A>, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        let request = NSMutableURLRequest(url: resource.url as URL)
        request.httpMethod = resource.method.rawValue
        
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
                let baseURL = request.url!.absoluteString
                request.url = URL(string: baseURL + query)
            } else {
                if let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: []) {
                    request.httpBody = jsonParams
                }
            }
           
        }
        URLSession.shared.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            // error is nil when request fails. Not nil when the request passes. However even if the request went through, the reponse can be of status code error 400 up or 500 up
            print("\n\(request.httpMethod) -- \(request.url!.absoluteString)")
            if let errorObj = error {
                DispatchQueue.main.async(execute: {
                    let networkError = JANetworkingError(error: errorObj)
                    completion(nil, networkError)
                })
            }else{
                DispatchQueue.main.async(execute: {
                    // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data: data))
                    let results = data.flatMap(resource.parse)
                    completion(results, networkError)
                })
            }
            
        }.resume()
    }
    
    // Load image
    public static func loadImage(url: String, completion:@escaping (UIImage?, JANetworkingError?) -> ()){
        JANetworking.loadImageMedia(url: url, type: .image, completion: completion)
    }
    
    public static func loadGIF(url: String, completion:@escaping (UIImage?, JANetworkingError?) -> ()){
        JANetworking.loadImageMedia(url: url, type: .gif, completion: completion)
    }
    
    static func loadImageMedia(url: String, type:MediaType, completion:@escaping (UIImage?, JANetworkingError?) -> ()){
        // Check local disk for image
        DispatchQueue.global(qos: .background).async {
            let localURL = locationForImageAtURL(url)
            if let image = localImageForURL(localURL: localURL, type: type) {
                DispatchQueue.main.async(execute: {
                    completion(image, nil)
                })
            } else {
                JANetworking.fetchImageDataWithURL(imageURL: url, completion: { (imageData:Data?, error:JANetworkingError?) in
                    var image:UIImage?
                    if let localURL  = localURL, let imageData = imageData {
                        switch type {
                        case .image:
                            image = UIImage(data: imageData)
                        case .gif:
                            image = UIImage.gifWithData(data: imageData)
                        }
                        if let _ = image , JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
                            JANetworking.writeImageToFile(imageData: imageData, imageURL: localURL)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        completion(image, error)
                    })
                })
            }
        }
    }
    
    private static func writeImageToFile(imageData:Data, imageURL:String) {
        let imageDirectory = imageDirectoryPath
        do {
            // add directory if it doesn't exist
            if !(imageDirectory as NSURL).checkResourceIsReachableAndReturnError(nil) {
                try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            // save file
            try imageData.write(to: URL(fileURLWithPath: imageURL), options: .atomic)
        } catch let fileError {
            print(fileError)
        }
    }
    
    private static func localImageForURL(localURL:String?, type:MediaType) -> UIImage? {
        let checkImage = FileManager.default
        if let localURL = localURL , checkImage.fileExists(atPath: localURL) && JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
            var image:UIImage?
            switch type {
            case .image:
                image = UIImage(contentsOfFile: localURL)
            case .gif:
                image = UIImage.gifWithURL(gifUrl: localURL)
            }
            return image
        }
        return nil
    }
    
    private static func fetchImageDataWithURL(imageURL:String, completion:@escaping (Data?, JANetworkingError?) -> ()) {
        URLSession.shared.dataTask(with: URL(string: imageURL)!, completionHandler: { (data, response, error) in
            if let errorObj = error {
                    let networkError = JANetworkingError(error: errorObj as Error)
                    completion(nil, networkError)
            }else{
                // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                // Ensure that there is no error in the reponse and in the server
                let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data: data))
                completion(data, networkError)
            }
            }) .resume()
    }
    
    public static func removeImageAtUrl(url:String) -> Bool {
        if let imageURL = locationForImageAtURL(url) {
            do {
                try FileManager.default.removeItem(atPath: imageURL)
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
            try FileManager.default.removeItem(at: imageDirectoryPath)
            return true
        } catch let fileError {
            print(fileError)
        }
        return false
    }
    
    private static func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        for (k, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }
    
    private static func locationForImageAtURL(_ url:String) -> String? {
        let imageDirectory = imageDirectoryPath
        var saveName = url
        saveName = saveName.replacingOccurrences(of: "/", with: "")
        let imageURL = imageDirectory.appendingPathComponent("\(saveName)").path
        
        return imageURL
    }
    
    private static var imageDirectoryPath:URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDirectory = documentsURL.appendingPathComponent("image_cache")
        return imageDirectory
    }
}

// ImageView Extension for convinience use

public extension UIImageView {
    func downloadImage(url: String, placeholder: UIImage? = nil){
        if let defaultImage = placeholder {
            image = defaultImage
        }
        JAImageManager.sharedManager.imageForUrl(imageUrl: url) { (image:UIImage?) in
            self.image = image
        }
    }
    
    func downloadGIF(url: String, placeholder: UIImage? = nil){
        if let defaultImage = placeholder {
            image = defaultImage
        }
        JANetworking.loadImageMedia(url: url, type: .gif) { (image, error) in
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
