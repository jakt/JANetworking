//
//  PEConnectivityManager.swift
//  PeeR
//
//  Created by Enrique on 2/2/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import CoreTelephony

//public let weakSignalNotifcationName = "JANetworkingWeakSignal"
public let noSignalNotifcationName = "JANetworkingNoSignal"
public let regainSignalNotifcationName = "JANetworkingRegainSignal"

public class JAConnectivityManager{

    static let sharedInstance = JAConnectivityManager()
    var reachability: Reachability?

    public func setupReachability(regainConnectionBlock:(()->Void)? = nil, loseConnectionBlock:(()->Void)? = nil){
        reachability = Reachability()
        
        // Notifiers
        reachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("NOTIFIER: Reachable via WiFi")
                } else {
                    print("NOTIFIER: Reachable via Cellular")
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: regainSignalNotifcationName), object: nil)
                regainConnectionBlock?()
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("NOTIFIER: Not reachable")
                // Post notification for any controller to modify for no connection
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: noSignalNotifcationName), object: nil)
                loseConnectionBlock?()
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    // Checks if there is any connection at all
    public func isConnectionReachable() -> Bool{
        let networkStatus = reachability?.currentReachabilityStatus
        
        if(networkStatus == Reachability.NetworkStatus.notReachable){
            print("User has NO CONNECTION")
            return false
        }
        return true
    }
    
    // Checks if connection is unreachable or on 1x/Edge. Returns false if connection is LTE, 3G, or WiFi
    public func isConnectionSlow() -> Bool {
        let networkStatus = reachability?.currentReachabilityStatus
        
        if(networkStatus == Reachability.NetworkStatus.notReachable){
//            print("User has NO CONNECTION")
        }else if(networkStatus == Reachability.NetworkStatus.reachableViaWiFi){
//            print("User is on Wifi")
            return false
        }else if(networkStatus == Reachability.NetworkStatus.reachableViaWWAN){
            if let currentConnection = checkCellConnection() {
                if currentConnection == CTRadioAccessTechnologyLTE {
//                    print("User is on LTE")
                    return false
                }
                else if currentConnection == CTRadioAccessTechnologyWCDMA ||
                    currentConnection == CTRadioAccessTechnologyHSDPA ||
                    currentConnection == CTRadioAccessTechnologyHSUPA ||
                    currentConnection == CTRadioAccessTechnologyCDMAEVDORev0 ||
                    currentConnection == CTRadioAccessTechnologyCDMAEVDORevB ||
                    currentConnection == CTRadioAccessTechnologyCDMAEVDORevA ||
                    currentConnection == CTRadioAccessTechnologyeHRPD {
//                        print("User is on a 3G Network")
                        return false
                }
                else{
//                    print("User is on a 1x/Edge Network")
                }
            }else{
                print("Error ReachableViaWiFi unknown cell connection")
            }
        }
        return true
    }
    
    func checkCellConnection() -> String? {
        let telephonyInfo = CTTelephonyNetworkInfo()
        let currentRadio = telephonyInfo.currentRadioAccessTechnology
        return currentRadio
    }
}
