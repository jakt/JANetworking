//
//  User.swift
//  rs_exchange
//
//  Created by Eli Liebman on 7/7/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import CoreData
import JANetworking

public final class User:NSObject {
    
    // Login
    static func login(email: String, password: String) -> JANetworkingResource<User>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/login/")!
        let params = ["email": email, "password": password]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let userDictionary = dictionary["user"] as? JSONDictionary else { return nil }
            // Save to locksmith user credentials
            return nil
        })
    }
    
    // Register
    static func register(email: String, password: String, accessCode: String) -> JANetworkingResource<User>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/registration/")!
        let params = ["email": email, "password": password, "code":accessCode]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let userDictionary = dictionary["user"] as? JSONDictionary else { return nil }
            return nil
        })
    }
    
    // Update User Phone
    func updatePhoneNumber(newNumber:String) -> JANetworkingResource<User>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/user/")!
        let params:[String:Any?] = ["first_name": nil, "last_name": nil, "middle_initial": nil, "username": nil, "phone_number": newNumber]
        return JANetworkingResource(method: .PUT, url: url, headers: nil, params: params, parseJSON: { json in
            guard let userDictionary = json as? JSONDictionary else { return nil }
            return nil
        })
    }
    
    // Refresh token
    static func refreshToken(_ token: String) -> JANetworkingResource<String> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/token-refresh/")!
        let params = ["token": token]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let newToken = dictionary["token"] as? String else { return nil }
            return newToken
        })
    }
    
    // Fetch user data
    static func userDetails() -> JANetworkingResource<User>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/user/")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return nil
        })
    }

}
