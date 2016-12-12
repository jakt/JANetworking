//
//  JANetworkingConfiguration.swift
//  JANetworking
//
//  Created by Eli Liebman on 7/12/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import Foundation

public typealias LoadTokenBlock = ()->(String?)
public typealias SaveTokenBlock = (String?) -> ()
public typealias RefreshTimerBlock = () -> ()

public final class JANetworkingConfiguration {
    
    public enum NetworkEnvironment {
        case development
        case staging
        case production
    }
    
    public static let sharedConfiguration = JANetworkingConfiguration()
    public var automaticallySaveImageToDisk = true
    public static var unauthorizedRetryLimit:Int = 1

    public private(set) var configurationHeaders = ["Content-Type":"application/json",
                                                    "Accept":"application/json"]
    
    private var loadToken: LoadTokenBlock? = {() -> (String?) in
        print("Networking Configuration Load Token not set")
        return nil
    }
    
    public private(set) var currentEnvironment:NetworkEnvironment = .development

    public class var baseURL:String {
        get {
            switch sharedConfiguration.currentEnvironment {
            case .development:
                return sharedConfiguration.developmentBaseURL
            case .staging:
                return sharedConfiguration.stagingBaseURL
            case .production:
                return sharedConfiguration.productionBaseURL
            }
        }
    }
        
    public class func set(environment:NetworkEnvironment) {
        sharedConfiguration.currentEnvironment = environment
    }
    
    private var developmentBaseURL = ""
    private var stagingBaseURL = ""
    private var productionBaseURL = ""
    
    private var saveToken: SaveTokenBlock? = { (token) in
        print("Networking Configuration Save Token not set")
    }

    public class func setSaveToken(block:@escaping SaveTokenBlock) {
        sharedConfiguration.saveToken = block
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = nil
        resetRefreshTimer()
    }
    
    public class func setLoadToken(block:@escaping LoadTokenBlock) {
        sharedConfiguration.loadToken = block
    }

    public class var token:String? {
        get {
            return sharedConfiguration.loadToken?()
        }
        set {
            sharedConfiguration.saveToken?(newValue)
        }
    }

    public class func set(header:String, value:String?) {
        sharedConfiguration.configurationHeaders[header] = value
    }
    
    public class func setBaseURL(development:String, staging:String, production:String) {
        sharedConfiguration.developmentBaseURL = development
        sharedConfiguration.stagingBaseURL = staging
        sharedConfiguration.productionBaseURL = production
    }
    
    public class func setUpRefreshTimer(timeInterval:TimeInterval, block:RefreshTimerBlock?) {
        sharedConfiguration.refreshTimerBlock = block
        sharedConfiguration.refreshTimerInterval = timeInterval
        if block == nil {
            sharedConfiguration.refreshTimer?.invalidate()
        } else {
            resetRefreshTimer()
        }
    }
    
    private var refreshTimer:Timer?
    private var refreshTimerInterval:TimeInterval = 600
    private var refreshTimerBlock: RefreshTimerBlock?
    
    public class func resetRefreshTimer() {
        print("Refresh timer reset")
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = Timer.scheduledTimer(timeInterval: sharedConfiguration.refreshTimerInterval, target: sharedConfiguration, selector: #selector(sharedConfiguration.refreshTimerFired), userInfo: nil, repeats: true)
    }
    
    @objc private func refreshTimerFired() {
        refreshTimerBlock?()
    }
    
}
