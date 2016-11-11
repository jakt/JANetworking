//
//  AppDelegate.swift
//  rs_exchange
//
//  Created by Eli Liebman on 6/28/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import JANetworking

let baseUrl = "http://demo3646012.mockable.io"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Create CoreData context
        
        // Setup for JANetworking
        JANetworkingConfiguration.setBaseURL(development: "https://rs-exchange-dev.herokuapp.com/api", staging: "https://rs-exchange-staging.herokuapp.com/api", production: "https://rs-exchange-live.herokuapp.com/api")
        JANetworkingConfiguration.set(environment: .staging)
        
        JANetworkingConfiguration.setLoadToken { () -> (String?) in
            return UserDefaults.standard.object(forKey: "token") as? String
        }
        
        JANetworkingConfiguration.setSaveToken { (token) in
            UserDefaults.standard.set(token, forKey: "token")
        }
        
        JANetworkingConfiguration.unauthorizedRetryLimit = 1
        JANetworking.delegate = self
        
        //        refreshToken(completion:nil)
        
        // FOR TESTING, SET THE TOKEN TO AN OLD, INVALID TOKEN AND SEE IF JANETWORKING REFRESHES THE TOKEN CORRECTLY
        JANetworkingConfiguration.token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYjNlN2RmNGUtY2E0My00YTk5LTk3OWQtNGI5MWNkOGVhNzc3IiwiZW1haWwiOiJ1QHUuY29tIiwiZXhwIjoxNDc4MjA4MjU4LCJ1c2VybmFtZSI6InVAdS5jb20iLCJvcmlnX2lhdCI6MTQ3ODIwNzM4M30.3XTUV7T2LzpyR4LVy5Kv--ICXfIjN4hvAV-apBNOUqo"
        
        JANetworking.loadJSON(resource: User.userDetails()) { (data, error) in
            if error == nil {
                print("success")
            } else {
                print("error")
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //        refreshToken(completion:nil)
    }
    
    func refreshToken(completion:((Bool)->Void)?) {
        // Auto log user in using the user credential saved in locksmith
        let username = "u@u.com"
        let password = "Jakt456!"
        JANetworkingConfiguration.token = nil
        
        JANetworking.loadJSON(resource: User.login(email: username, password: password), completion: { (data, error) in
            if error == nil {
                print("success")
                completion?(true)
            } else {
                print("error")
                completion?(false)
            }
        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func parseParamsSchema(_ urlString:String) -> [String:String] {
        var dictionary:[String:String] = [:]
        
        let urlComponents = urlString.components(separatedBy: "&")
        for keyValuePair in urlComponents {
            let pairComponents = keyValuePair.components(separatedBy: "=")
            if pairComponents.count > 2 {
                dictionary[pairComponents[0]] = pairComponents[1]
                
            }
        }
        return dictionary
    }
}

extension AppDelegate:JANetworkDelegate {
    func updateToken(completion: @escaping ((Bool) -> Void)) {
        print("trying to refresh")
        self.refreshToken(completion: completion)
    }
    
    func unauthorizedCallAttempted() {
        print("unauth")
    }
}

