//
//  JANetworking.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

public protocol JANetworkDelegate: class {
    func updateToken(completion: @escaping ((Bool)->Void))
    func unauthorizedCallAttempted()
}

import Foundation

public final class JANetworking {
    // Load json request
    
    weak public static var delegate:JANetworkDelegate?
    
    public static func loadJSON<A>(resource: JANetworkingResource<A>, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        createServerCall(resource: resource, useNextPage:false, retryCount:0, completion: completion)
    }
    
    public static func loadPagedJSON<A>(resource: JANetworkingResource<A>, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        createServerCall(resource: resource, useNextPage:true, retryCount:0, completion: completion)
    }
    
    private static func createServerCall<A>(resource: JANetworkingResource<A>, useNextPage:Bool, retryCount:Int, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        var url = resource.url as URL
        if useNextPage {
            if let next = nextPageUrl[resource.id] {
                // Key exists, now check if url exists
                if let validUrl = next {
                    url = validUrl
                } else {
                    // Last page has already been called
                    let err = JAError(field: "Paging error", message: "Last page reached, no new pages available")
                    let error = JANetworkingError(errorType: ErrorType.badRequest, statusCode: 1, errorData: [err])
                    completion(nil, error)
                }
            } else {
                // Key doesnt exist, first call of the paging request
            }
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        // Setup headers
        
        // Add default headers
        for (key, value) in JANetworkingConfiguration.sharedConfiguration.configurationHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let headers = resource.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Setup params
        if let params = resource.params {
            if resource.method == .GET {
                var stringParams:[String:String]
                if let sParams = params as? [String:String] {
                    stringParams = sParams
                } else if let sParams = convertToStringDictionary(dictionary: params) {
                    stringParams = sParams
                } else {
                    stringParams = [:]
                }
                let query = buildQueryString(fromDictionary: stringParams)
                let baseURL = request.url!.absoluteString
                let url = URL(string: baseURL + query)
                request.url = url
            } else {
                if let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: []) {
                    request.httpBody = jsonParams
                    //                    let convertedString = String(data: jsonParams, encoding: String.Encoding.utf8)
                }
            }
        }
        
        // Add the JSON Web Token if we have it
        if let token = JANetworkingConfiguration.token {
            request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            // error is nil when request fails. Not nil when the request passes. However even if the request went through, the reponse can be of status code error 400 up or 500 up
            if let errorObj = error {
                DispatchQueue.main.async(execute: {
                    let networkError = JANetworkingError(error: errorObj)
                    var tokenInvalid = networkError.statusCode == 401
                    if let errorData = networkError.errorData, let errorObj = errorData.first, let msg = errorObj.message, msg.contains("token") {
                        tokenInvalid = true
                    }
                    if tokenInvalid {
                        if retryCount <= JANetworkingConfiguration.unauthorizedRetryLimit, let delegate = delegate {
                            delegate.updateToken(completion: {(success:Bool) in
                                if success {
                                    let count = retryCount + 1
                                    createServerCall(resource: resource, useNextPage:useNextPage, retryCount: count, completion: completion)
                                } else {
                                    self.delegate?.unauthorizedCallAttempted()
                                    completion(nil, networkError)
                                }
                            })
                        } else {
                            delegate?.unauthorizedCallAttempted()
                            completion(nil, networkError)
                        }
                    } else {
                        completion(nil, networkError)
                    }
                })
            }else{
                DispatchQueue.main.async(execute: {
                    // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data: data))
                    let results = data.flatMap(resource.parse)
                    var tokenInvalid = networkError?.statusCode == 401
                    if let errorData = networkError?.errorData, let errorObj = errorData.first, let msg = errorObj.message, msg.contains("token") {
                        tokenInvalid = true
                    }
                    if tokenInvalid {
                        if retryCount <= JANetworkingConfiguration.unauthorizedRetryLimit, let delegate = delegate {
                            delegate.updateToken(completion: {(success:Bool) in
                                if success {
                                    let count = retryCount + 1
                                    createServerCall(resource: resource, useNextPage:useNextPage, retryCount: count, completion: completion)
                                } else {
                                    self.delegate?.unauthorizedCallAttempted()
                                    completion(results, networkError)
                                }
                            })
                        } else {
                            delegate?.unauthorizedCallAttempted()
                            completion(results, networkError)
                        }
                    } else {
                        // SUCCESS
                        saveNextPage(for: resource, data: data)
                        completion(results, networkError)
                    }
                })
            }
            
        }.resume()
    }
    
    private static var nextPageUrl:[String:URL?] = [:]
    private static func saveNextPage<A>(for resource:JANetworkingResource<A>, data:Data?) {
        guard let data = data else {return}
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        // Check for a JSON Web Token
        if let parsedData = json as? JSONDictionary, let next = parsedData["next"] as? String {
            nextPageUrl[resource.id] = URL(string: next)
        }
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
