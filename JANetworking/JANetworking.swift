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
        var params = resource.params as? [String:String]
        if params == nil, let anyParams = resource.params {
            params = convertToStringDictionary(dictionary: anyParams)
        }
        if let params = params {
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
        if let urlString = request.url?.absoluteString {
            print(urlString)
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
    
    private static func convertToStringDictionary(dictionary:[String:Any]) -> [String:String]? {
        var newDictionary:[String:String] = [:]
        for (key, value) in dictionary {
            if let value = value as? String {
                newDictionary[key] = value
            }else if let value = value as? [String:String] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
                    let convertedString = String(data: jsonData, encoding: String.Encoding.utf8) // the data will be converted to the string
//                    let stringWithoutQuotes = convertedString?.replacingOccurrences(of: "\"", with: "")
                    newDictionary[key] = "'\(convertedString)'"
                } catch {
                    print("params conversion to string failed")
                    return nil
                }
            } else if let value = value as? [String] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
                    let convertedString = String(data: jsonData, encoding: String.Encoding.utf8) // the data will be converted to the string
//                    let stringWithoutQuotes = convertedString?.replacingOccurrences(of: "\"", with: "")
                    newDictionary[key] = "'\(convertedString)'"
                } catch {
                    print("params conversion to string failed")
                    return nil
                }
            } else {
                newDictionary[key] = String(describing: value)
            }
        }
        return newDictionary
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
}
