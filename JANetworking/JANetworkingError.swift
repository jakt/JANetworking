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
    
    case BadRequest
    case Unauthorized
    case NotFound
    
    case InternalServerError
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    
    init(response: NSHTTPURLResponse) {
        // Check what kind of error type based on response
        switch response.statusCode {
            
        // Client error response
        case 400:
            self = .BadRequest
            break
        case 401:
            self = .Unauthorized
            break
        case 404:
            self = .NotFound
            break
            
        // Server error message
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
        case .Unknown:
            return "Unknown"
            
        // Client error
        case .BadRequest:
            return "Bad Request"
        case .Unauthorized:
            return "Access Denied"
        case .NotFound:
            return "Not Found"
            
        // Server error
        case .InternalServerError:
            return "Internal Server Error"
        case .BadGateway:
            return "Bad Gateway"
        case .ServiceUnavailable:
            return "Service Unavailable"
        case .GatewayTimeout:
            return "Gateway Timeout"
        }
    }
    
    public func errorMessage() -> String {
        switch self {
        case .Unknown:
            return "Sorry. Unexpected error."
            
        // Client error
        case .BadRequest:
            return "This response means that server could not understand the request due to invalid syntax."
        case .Unauthorized:
            return "Authentication is needed to get requested response. This is similar to 403, but in this case, authentication is possible."
        case .NotFound:
            return "Server can not find requested resource. This response code probably is most famous one due to its frequency to occur in web."
            
        // Server error
        case .InternalServerError:
            return "The server has encountered a situation it doesn't know how to handle."
        case .BadGateway:
            return "This error response means that the server, while working as a gateway to get a response needed to handle the request, got an invalid response."
        case .ServiceUnavailable:
            return "The server is not ready to handle the request. Common causes are a server that is down for maintenance or that is overloaded. Note that together with this response, a user-friendly page explaining the problem should be sent. This responses should be used for temporary conditions and the Retry-After: HTTP header should, if possible, contain the estimated time before the recovery of the service. The webmaster must also take care about the caching-related headers that are sent along with this response, as these temporary condition responses should usually not be cached."
        case .GatewayTimeout:
            return "This error response is given when the server is acting as a gateway and cannot get a response in time."
        }
    }
}

public struct JANetworkingError {
    public let errorType: ErrorType
    public var error: NSError? = nil // Original object
    public var statusCode: Int? = nil
}

extension JANetworkingError {
    // Error init. An NSError object exist
    public init(error: NSError) {
        // TODO: Make sure to parse the NSError and know what the actual error is
        self.error = error
        self.errorType = .Unknown
    }
    
    // Optional. Based on the response, it can still be an error depending on the status code
    public init?(response: NSURLResponse?) {
        // TODO: Make sure to check if the server reponse is success with 200 code but also the result object could containt `{ success: false, message:"Some error message" }`
        guard let response = response as? NSHTTPURLResponse where response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        self.errorType = ErrorType(response: response)
        self.statusCode = response.statusCode
    }
}
