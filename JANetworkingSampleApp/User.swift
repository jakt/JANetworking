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
    
    public var username:String
    public var id:String
    public var phoneNumber:Int
    
    init?(json:JSONDictionary) {
        guard let username = json["username"] as? String,
            let id = json["id"] as? String,
            let phone = json["phone_number"] as? Int else {
                return nil
        }
        self.username = username
        self.id = id
        self.phoneNumber = phone
    }
    
    //login
    public static func login(username: String, password: String) -> JANetworkingResource<User?>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/login/")!
        let params = ["username" : username, "password" : password]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let userDictionary = dictionary["user"] as? JSONDictionary else {return nil}
            // Parse and save server info here! If using core data, pass in the ManagedObjectContext and save the data in this block.
            return User(json: userDictionary)
        })
    }
    
    // Register
    static func register(username: String, password: String) -> JANetworkingResource<User?>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/registration/")!
        let params = ["username": username, "password": password]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let userDictionary = dictionary["user"] as? JSONDictionary else { return nil }
            // Parse and save server info here! If using core data, pass in the ManagedObjectContext and save the data in this block.
            return User(json: userDictionary)
        })
    }
    
    // Update User Phone
    func updatePhoneNumber(newNumber:String) -> JANetworkingResource<User?>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/user/")!
        let params:[String:Any?] = ["first_name": nil, "last_name": nil, "middle_initial": nil, "username": nil, "phone_number": newNumber]
        return JANetworkingResource(method: .PUT, url: url, headers: nil, params: params, parseJSON: { json in
            guard let userDictionary = json as? JSONDictionary else { return nil }
            // Parse and save server info here! If using core data, pass in the ManagedObjectContext and save the data in this block.
            return User(json: userDictionary)
        })
    }
    
    // Refresh token
    static func refreshToken(_ token: String) -> JANetworkingResource<String?> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/token-refresh/")!
        let params = ["token": token]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary, let newToken = dictionary["token"] as? String else { return nil }
            return newToken
        })
    }
    
    // Fetch user data
    static func userDetails() -> JANetworkingResource<User?>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/auth/user/")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return User(json: dictionary)

        })
    }

}
