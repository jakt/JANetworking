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
    case unknown
    
    // Apple docs for nsurlerrors
    // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes
    case nsurlError
    
    case invalidToken
    
    case badRequest
    case unauthorized
    case notFound
    case methodNotAllowed
    case internalServerError
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    
    init(response: HTTPURLResponse, error: JAError?) {
        // Check what kind of error type based on response
        switch response.statusCode {
            
        // Response Error
        case 400:
            if error?.field == "token" && error?.message == "Signature has expired." { // Check for invalid token
                self = .invalidToken
            }else {
                self = .badRequest
            }
            break
        case 401:
            self = .unauthorized
            break
        case 404:
            self = .notFound
            break
        case 405:
            self = .methodNotAllowed
            break
        case 500:
            self = .internalServerError
            break
        case 502:
            self = .badGateway
            break
        case 503:
            self = .serviceUnavailable
            break
        case 504:
            self = .gatewayTimeout
            break
            
        default:
            self = .unknown
        }
    }
    
    public func errorTitle() -> String {
        switch self {
        case .invalidToken:
            return "Invalid Token"
            
        // Response Error
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Access Denied"
        case .notFound:
            return "Not Found"
        case .methodNotAllowed:
            return "Method Not Allowed"
        case .internalServerError:
            return "Internal Server Error"
        case .badGateway:
            return "Bad Gateway"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .gatewayTimeout:
            return "Gateway Timeout"
            
        case .unknown:
            return "Unknown"
            
        case .nsurlError:
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
    // Error init. An Error object exist
    public init(error: Error) {
        self.errorType = .nsurlError
        let errorObject = JAError(field: nil, message: error.localizedDescription)
        self.errorData = [errorObject]
    }
    
    // Optional. Based on the response, it can still be an error depending on the status code
    public init?(responseError: URLResponse?, serverError: [JAError]?) {
        // Make sure reponse exist and the status code is between the 2xx range
        guard let response = responseError as? HTTPURLResponse , !(response.statusCode >= 200 && response.statusCode < 300) else {
            return nil
        }
        self.errorType  = ErrorType(response: response, error: serverError?.first)
        self.statusCode = response.statusCode
        self.errorData = serverError
    }
    
    // Parse the sever error ensuring that the server has an error or not
    public static func parseServerError(data: Data?) -> [JAError]?{
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
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

