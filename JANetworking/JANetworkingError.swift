//
//  JANetworkingError.swift
//  JANetworking
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

// Error bases on https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes

public enum ErrorType {
    case Unknown
    
    // Apple docs for nsurlerrors
    // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes
    case NSURLError
    
    case InvalidToken
    
    case BadRequest
    case Unauthorized
    case NotFound
    case MethodNotAllowed
    case InternalServerError
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    
    init(response: NSHTTPURLResponse, error: JAError?) {
        // Check what kind of error type based on response
        switch response.statusCode {
            
        // Response Error
        case 400:
            if error?.field == "token" && error?.message == "Signature has expired." { // Check for invalid token
                self = .InvalidToken
            }else {
                self = .BadRequest
            }
            break
        case 401:
            self = .Unauthorized
            break
        case 404:
            self = .NotFound
            break
        case 405:
            self = .MethodNotAllowed
            break
        case 500:
            self = .InternalServerError
            break
        case 502:
            self = .BadGateway
            break
        case 503:
            self = .ServiceUnavailable
            break
        case 504:
            self = .GatewayTimeout
            break
            
        default:
            self = .Unknown
        }
    }
    
    public func errorTitle() -> String {
        switch self {
        case .InvalidToken:
            return "Invalid Token"
            
        // Response Error
        case .BadRequest:
            return "Bad Request"
        case .Unauthorized:
            return "Access Denied"
        case .NotFound:
            return "Not Found"
        case .MethodNotAllowed:
            return "Method Not Allowed"
        case .InternalServerError:
            return "Internal Server Error"
        case .BadGateway:
            return "Bad Gateway"
        case .ServiceUnavailable:
            return "Service Unavailable"
        case .GatewayTimeout:
            return "Gateway Timeout"
            
        case .Unknown:
            return "Unknown"
            
        case .NSURLError:
            return "NSURLError"
        }
    }
}

public struct JAError {
    public var field: String? = nil
    public var message: String? = nil
}

public struct JANetworkingError {
    public let errorType: ErrorType
    public var statusCode: Int? = nil
    public var errorData: [JAError]? = nil
}

extension JANetworkingError {
    // Error init. An NSError object exist
    public init(error: NSError) {
        self.errorType = .NSURLError
        let errorObject = JAError(field: nil, message: error.localizedDescription)
        self.errorData = [errorObject]
    }
    
    // Optional. Based on the response, it can still be an error depending on the status code
    public init?(responseError: NSURLResponse?, serverError: [JAError]?) {
        // Make sure reponse exist and the status code is between the 2xx range
        guard let response = responseError as? NSHTTPURLResponse where !(response.statusCode >= 200 && response.statusCode < 300) else {
            return nil
        }
        self.errorType  = ErrorType(response: response, error: serverError?.first)
        self.statusCode = response.statusCode
        self.errorData = serverError
    }
    
    // Parse the sever error ensuring that the server has an error or not
    public static func parseServerError(data: NSData?) -> [JAError]?{
        if let data = data {
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let results = json as? JSONDictionary else { return nil }
            guard let errors = results["errors"] as? [JSONDictionary] else { return nil }
            let errorArray = errors.map({
                JAError(field: $0["field"] as? String, message: $0["message"] as? String)
            })
            
            return errorArray
        }
 
        return nil
    }
}

