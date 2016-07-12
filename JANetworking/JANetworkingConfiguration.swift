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
    
    private var loadToken: LoadTokenBlock?
    private var saveToken: SaveTokenBlock?
    
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
}