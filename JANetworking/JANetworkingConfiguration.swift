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
public typealias RefreshTimerBlock = () -> ()

public final class JANetworkingConfiguration {
    
    public static let sharedConfiguration = JANetworkingConfiguration()
    public var automaticallySaveImageToDisk = true

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
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = nil
        resetRefreshTimer()
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
    
    
    public class func setUpRefreshTimer(timeInterval:NSTimeInterval, block:RefreshTimerBlock?) {
        sharedConfiguration.refreshTimerBlock = block
        sharedConfiguration.refreshTimerInterval = timeInterval
        if block == nil {
            sharedConfiguration.refreshTimer?.invalidate()
        } else {
            resetRefreshTimer()
        }
    }
    
    private var refreshTimer:NSTimer?
    private var refreshTimerInterval:NSTimeInterval = 600
    private var refreshTimerBlock: RefreshTimerBlock?
    
    public class func resetRefreshTimer() {
        print("Refresh timer reset")
        sharedConfiguration.refreshTimer?.invalidate()
        sharedConfiguration.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(sharedConfiguration.refreshTimerInterval, target: sharedConfiguration, selector: #selector(sharedConfiguration.refreshTimerFired), userInfo: nil, repeats: true)
    }
    
    @objc private func refreshTimerFired() {
        refreshTimerBlock?()
    }
    
}