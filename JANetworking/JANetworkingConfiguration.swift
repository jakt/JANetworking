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


/// This class is used to configure all aspects of the library. A singleton "sharedConfiguration" is created on load and holds onto all default settings and is then accessed by most other classes when configuring.
/// To override any defaults, override these functions within applicationDidFinishLaunchingWithOptions in the AppDelegate

public final class JANetworkingConfiguration {
    
    public static let sharedConfiguration = JANetworkingConfiguration()
    
    
    // MARK: - Environment
    
    public enum NetworkEnvironment {
        case development
        case staging
        case production
    }
    
    public private(set) var currentEnvironment:NetworkEnvironment = .development

    private var developmentBaseURL = ""
    private var stagingBaseURL = ""
    private var productionBaseURL = ""
    
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
    
    /// Sets the base URL's used for all types of environments
    public class func setBaseURL(development:String, staging:String, production:String) {
        sharedConfiguration.developmentBaseURL = development
        sharedConfiguration.stagingBaseURL = staging
        sharedConfiguration.productionBaseURL = production
    }
    
    /// Sets the network environment that will be used for all server calls
    public class func set(environment:NetworkEnvironment) {
        sharedConfiguration.currentEnvironment = environment
    }
    
    
    // MARK: - Tokens
    
    public class var token:String? {
        get {
            return sharedConfiguration.loadToken?()
        }
        set {
            sharedConfiguration.saveToken?(newValue)
        }
    }
    
    public private(set) var invalidTokenServerResponseText:[String] = ["token", "expired"]
    public private(set) var invalidTokenHTTPStatusCodes:[Int] = [401]
    
    private var loadToken: LoadTokenBlock? = {() -> (String?) in
        print("Networking Configuration Load Token not set")
        return nil
    }
    
    private var saveToken: SaveTokenBlock? = { (token) in
        print("Networking Configuration Save Token not set")
    }
    
    /// Configure a block that will save and store a valid server token, preferably in the keychain
    public class func setSaveToken(block:@escaping SaveTokenBlock) {
        sharedConfiguration.saveToken = block
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = nil
        resetRefreshTimer()
    }
    
    /// Configure a block that will return a valid server token that has been saved for JANetworking to use.
    public class func setLoadToken(block:@escaping LoadTokenBlock) {
        sharedConfiguration.loadToken = block
    }
    
    /// Set these variables in order for JANetworking to interpret responses from the back end that signify a token is expired.
    public class func setInvalidTokenInfo(serverResponseText:[String], HTTPStatusCodes:[Int]) {
        sharedConfiguration.invalidTokenServerResponseText = serverResponseText
        sharedConfiguration.invalidTokenHTTPStatusCodes = HTTPStatusCodes
    }

    
    // MARK: - Server Calls
    
    public private(set) var unauthorizedRetryLimit:Int = 1
    
    public private(set) var configurationHeaders:[String:String] = [:]

    /// Set all default headers to be included in all
    public class func set(header:String, value:String) {
        sharedConfiguration.configurationHeaders[header] = value
    }
    
    /// Set the number of times a server call tries to refresh the token before failing
    public class func setUnauthorizedRetryLimit(_ limit:Int) {
        sharedConfiguration.unauthorizedRetryLimit = limit
    }
    
    // MARK: - Images
    
    public static var automaticallySaveImageToDisk = true
    
    
    // MARK: - Refresh Timer Code
    
    private var refreshTimer:Timer?
    private var refreshTimerInterval:TimeInterval = 600
    
    /// Set the token refresh interval and the block that will trigger anytime the timer completes.
    /// When the timer is triggered, it will call the "updateToken" token on the current JANetworkingDelegate. This delegate must be set up for the refresh timer to function properly.
    public class func setUpRefreshTimer(timeInterval:TimeInterval) {
        sharedConfiguration.refreshTimerInterval = timeInterval
        resetRefreshTimer()
    }
    
    public class func resetRefreshTimer() {
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = Timer.scheduledTimer(timeInterval: sharedConfiguration.refreshTimerInterval, target: sharedConfiguration, selector: #selector(sharedConfiguration.refreshTimerFired), userInfo: nil, repeats: true)
    }
    
    @objc private func refreshTimerFired() {
        JANetworking.delegate?.updateToken(completion: { (success) in
            //
        })
    }
    
}
