//
//  JANetworking.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

@objc public protocol JANetworkDelegate: class {
    /// Function that will be called anytime a server call is made with an expired or bad token. This method must refresh the token so that it will be valid next time JANetworking calls retries the server call.
    func updateToken(completion: @escaping ((Bool)->Void))
    /// Function that will be called when updateToken fails to fix the token issue.
    func unauthorizedCallAttempted()
    /// Function that will be called when the token status changes
    @objc optional func tokenStatusChanged()
}


import Foundation

public enum TokenStatus {
    case invalidRefreshedSuccessfully
    case invalidCantRefresh
    case valid
}

public final class JANetworking {
    
    private static let noMorePagesIdentifier = "No more pages"
    weak public static var delegate:JANetworkDelegate?
    
    public static var tokenStatus:TokenStatus? {
        didSet {
            if tokenStatus != oldValue {
               delegate?.tokenStatusChanged?()
            }
        }
    }
    
    // Var where all paginated urls are stored
    private static var nextPageUrl:[String:String] = [:]
    private static var currentTasks:[NSURLRequest:URLSessionTask] = [:] {
        didSet {
            let tasksOngoing = currentTasks.count > 0
            DispatchQueue.main.async {
                // Run on main thread since this can update UI
                UIApplication.shared.isNetworkActivityIndicatorVisible = tasksOngoing  // Show network indicator if any tasks are still happening
            }
        }
    }
    
    // MARK: - Public JSON Requests
    
    /// Loads a JANetworkingResource from the server and returns the results
    public static func loadJSON<A>(resource: JANetworkingResource<A>, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        createServerCall(resource: resource, useNextPage:false, retryCount:0, completion: completion)
    }
    
    /// Loads a JANetworkingResource from the server and returns the results
    /// This is specifically used to try logging in. The difference between this and the normal loadJSON is these resources are only tried once and never retried
    public static func loadLoginJSON<A>(resource: JANetworkingResource<A>, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        createServerCall(resource: resource, useNextPage:false, retryCount:Int.max, completion: completion)
    }
    
    /// Loads a JANetworkingResource from the server and returns the next page. The next time this function is called on the same resource, the page index will move up. This will continue until there are no more pages to load at which point an error will be returned.
    /// Page limit is the page count above which the function stops returning values
    /// Paged URL's need to be in the format of "<main URL>&page=8"
    public static func loadPagedJSON<A>(resource: JANetworkingResource<A>, pageLimit:Int? = nil, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        if !isNextPageAvailable(for: resource, pageLimit: pageLimit) {
            let err = JAError(field: "Paging error", message: "Last page reached, no new pages available")
            let error = JANetworkingError(errorType: ErrorType.badRequest, statusCode: 1, errorData: [err])
            completion(nil, error)
            return
        }
        createServerCall(resource: resource, useNextPage:true, retryCount:0, completion: completion)
    }
    
    /// Returns a boolean signifying whether or not the resource being handed in has any more pages to load. Will always return true for the first page a resource even if the resource isn't paginated.
    /// Paged URL's need to be in the format of "<main URL>&page=8"
    public static func isNextPageAvailable<A>(for resource:JANetworkingResource<A>, pageLimit:Int? = nil) -> Bool {
        
        guard let next = nextPageUrl[resource.id] else { return true } // If false, this is the first call being made on this resource.
        
        guard next != noMorePagesIdentifier else { return false } // If false, the last page has already been hit
        
        if let pageLimit = pageLimit { // If false, this resource is not page limited and next page url is valid
            
            // Find the page number within the URL string
            let andComponents = next.components(separatedBy: "&")
            var pageInt:Int?
            for component in andComponents {
                if component.contains("page=") {
                    let pageComponents = component.components(separatedBy: "page=")
                    if let nextPageString = pageComponents.last, let nextPageCount = Int(nextPageString) {
                        pageInt = nextPageCount
                        break
                    }
                }
            }
            if let nextPageCount = pageInt, nextPageCount > pageLimit {
                return false  // There is a valid next page but the pre-defined page limit has been reached
            }
        }
        return true  // Either there's no page limit or the "next" url is under the page limit
    }
    
    
    // MARK: - Private functions
    
    /// Main function within JANetworking. Fetches data from the server and returns it in a completion block
    private static func createServerCall<A>(resource: JANetworkingResource<A>, useNextPage:Bool, retryCount:Int, completion:@escaping (A?, _ err: JANetworkingError?) -> ()){
        
        // Check if theres a valid nextPage url (only if useNextPage is TRUE)
        var nextUrl:URL?
        if useNextPage {
            if let next = nextPageUrl[resource.id] {
                // Key exists, now check if url exists
                if next != noMorePagesIdentifier {
                    nextUrl = URL(string:next)
                } else {
                    // Last page has already been called
                    let err = JAError(field: "Paging error", message: "Last page reached, no new pages available")
                    let error = JANetworkingError(errorType: ErrorType.badRequest, statusCode: 1, errorData: [err])
                    completion(nil, error)
                    return
                }
            } else {
                // Key doesnt exist, first call of the paging request. Continue as normal
            }
        }

        // Create the request object
        let request = NSMutableURLRequest(url: resource.url)
        
        // Setup the full url string
        if let nextUrl = nextUrl {
            request.url = nextUrl  // If a valid paginated url exists, use it directly
        } else if let params = resource.params {
            // Setup params if needed but only if next page isn't valid
            if resource.method == .GET {
                var stringParams:[String:String] = [:]
                if let sParams = params as? [String:String] {
                    stringParams = sParams
                } else if let sParams = convertToStringDictionary(dictionary: params) {
                    stringParams = sParams
                }
                let query = buildQueryString(fromDictionary: stringParams)
                let baseURL = request.url!.absoluteString
                let url = URL(string: baseURL + query)
                request.url = url
            } else {
                if let jsonParams = try? JSONSerialization.data(withJSONObject: params, options: []) {
                    request.httpBody = jsonParams
                }
            }
        }
        request.httpMethod = resource.method.rawValue
        
        // Add default headers
        for (key, value) in JANetworkingConfiguration.sharedConfiguration.configurationHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        // Add any additional custom headers for this resource
        if let headers = resource.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add the JSON Web Token if we have it
        if let token = JANetworkingConfiguration.token {
            request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Begin the actual server call
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            // Remove the task from the running list
            currentTasks.removeValue(forKey: request)
            
            // error is nil when request passes, not nil when the request fails. However even if the request returns NO error, the reponse can be of status code error 400 up or 500 up
            DispatchQueue.main.async(execute: {
                if let errorObj = error {
                    let networkError = JANetworkingError(error: errorObj)
                    evaluateError(networkError: networkError, retryCount: retryCount, completion: { (tokenStatus) in
                        switch tokenStatus {
                        case .invalidRefreshedSuccessfully:
                            // Retry the same server call now that the token as been updated.
                            self.tokenStatus = tokenStatus
                            let count = retryCount + 1
                            createServerCall(resource: resource, useNextPage:useNextPage, retryCount: count, completion: completion)
                        case .invalidCantRefresh:
                            // The server call failed because of token issues but was unable to resolve itself.
                            self.tokenStatus = tokenStatus
                            completion(nil, networkError)
                        case .valid:
                            // This error is NOT token related. Return the error as normal.
                            completion(nil, networkError)
                            // Token status is NOT being updated here because the an error occurred during the server call which means the token may not have even been validated yet.
                        }
                    })
                }else{
                    // Successful request, HOWEVER the reponse can have an error with status code 400 and up (Errors)
                    var results = data.flatMap(resource.parse)
                    if results == nil, let responseObj = response as? HTTPURLResponse {
                        let successData = ["StatusCode":responseObj.statusCode] as JSONDictionary
                        results = resource.parseJson(successData)
                    }
                    
                    // Ensure that there is no error in the reponse and in the server
                    let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data: data))
                    evaluateError(networkError: networkError, retryCount: retryCount, completion: { (tokenStatus) in
                        switch tokenStatus {
                        case .invalidRefreshedSuccessfully:
                            // Retry the same server call now that the token as been updated.
                            self.tokenStatus = tokenStatus
                            let count = retryCount + 1
                            createServerCall(resource: resource, useNextPage:useNextPage, retryCount: count, completion: completion)
                        case .invalidCantRefresh:
                            // The server call failed because of token issues but was unable to resolve itself.
                            self.tokenStatus = tokenStatus
                            completion(results, networkError)
                        case .valid:
                            // Server call was successful and token is valid. There still may be a valid non-token related error being returned here. This is where all successful server calls return data. For paginated server calls, save the next page URL if it's returned.
                            if networkError == nil {
                                // Token status is only updated if there is NO error. If there is an error, the token may not be validated yet.
                                self.tokenStatus = tokenStatus
                            }
                            saveNextPage(for: resource, data: data)
                            completion(results, networkError)
                        }
                    })
                }
            })
        }
        task.resume()
        // Add the task to the list of all current server calls
        JANetworking.currentTasks[request] = task
    }

    /// Evaluates whether or not the token is valid. If invalid, it tries to refresh it.
    private static func evaluateError(networkError: JANetworkingError?, retryCount:Int, completion:@escaping ((TokenStatus)->Void)) {
        guard let networkError = networkError else {
            completion(.valid)
            return
        }
        
        if networkError.errorType == .invalidToken {
            // TOKEN IS INVALID. Try to refresh the token and try again. If that fails, call the unauthorizedCallAttempted callback to alert the app.
            if retryCount <= JANetworkingConfiguration.sharedConfiguration.unauthorizedRetryLimit, let delegate = delegate {
                delegate.updateToken(completion: {(success:Bool) in
                    if success {
                        // Retry the same server call now that the token as been updated.
                        completion(.invalidRefreshedSuccessfully)
                    } else {
                        self.delegate?.unauthorizedCallAttempted()
                        completion(.invalidCantRefresh)
                    }
                })
            } else {
                // The server call failed because of token issues but was unable to resolve itself.
                delegate?.unauthorizedCallAttempted()
                completion(.invalidCantRefresh)
            }
        } else {
            // This error is NOT token related. Return the error as normal.
            completion(.valid)
        }
    }
    
    /// Will take the server response and parse out if a "next page" URL is returned with it. If so, the "next" URL is saved to be used next time the resource is handed into the loadPagedJSON function
    private static func saveNextPage<A>(for resource:JANetworkingResource<A>, data:Data?) {
        guard let data = data else {return}
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        // Check for a JSON Web Token
        if let parsedData = json as? JSONDictionary, let next = parsedData["next"] as? String {
            nextPageUrl[resource.id] = next
        } else {
            nextPageUrl[resource.id] = noMorePagesIdentifier
        }
    }
    
    private static func convertToStringDictionary(dictionary:JSONDictionary) -> [String:String]? {
        var newDictionary:[String:String] = [:]
        for (key, value) in dictionary {
            if let value = value as? String {
                newDictionary[key] = value
            } else if let value = value as? [String:String] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
                    if let convertedString = String(data: jsonData, encoding: String.Encoding.utf8) { // the data will be converted to a string
                        newDictionary[key] = "'\(convertedString)'"
                    }
                } catch {
                    print("params conversion to string failed")
                    return nil
                }
            } else if let value = value as? [String] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
                    if let convertedString = String(data: jsonData, encoding: String.Encoding.utf8) { // the data will be converted to a string
                        newDictionary[key] = "'\(convertedString)'"
                    }
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
