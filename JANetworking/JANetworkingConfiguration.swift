//
//  JANetworkingConfiguration.swift
//  JANetworking
//
//  Created by Eli Liebman on 7/12/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public typealias LoadTokenBlock = ()->(String?)
public typealias SaveTokenBlock = (token:String?) -> ()

public final class JANetworkingConfiguration {
    
    public static let sharedConfiguration = JANetworkingConfiguration()
    
    public private(set) var configurationHeaders = ["Content-Type":"application/json",
                                                    "Accept":"application/json"]
    
    private var loadToken: LoadTokenBlock? = {() -> (String?) in
        print("Networking Configuration Load Token not set")
        return nil
    }

    private var saveToken: SaveTokenBlock? = { (token) in
        print("Networking Configuration Save Token not set")
    }


    public class func setSaveToken(block:SaveTokenBlock) {
        sharedConfiguration.saveToken = block
    }
    
    public class func setLoadToken(block:LoadTokenBlock) {
        sharedConfiguration.loadToken = block
    }
    
    public class var token:String? {
        get {
            return sharedConfiguration.loadToken?()
        }
        set {
            sharedConfiguration.saveToken?(token: newValue)
        }
    }

    public class func set(header:String, value:String?) {
        sharedConfiguration.configurationHeaders[header] = value
    }
    

}