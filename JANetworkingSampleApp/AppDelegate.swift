//
//  AppDelegate.swift
//  rs_exchange
//
//  Created by Eli Liebman on 6/28/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import JANetworking

let tokenStatusNotificationName = NSNotification.Name.init("TokenStatusChanged")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup for JANetworking
        JANetworkingConfiguration.setBaseURL(development: "https://<DEV URL>", staging: "https://<STAGING URL>", production: "https://<PROD URL>")
        JANetworkingConfiguration.set(environment: .development)
        JANetworkingConfiguration.set(header: "Content-Type", value: "application/json")
        JANetworkingConfiguration.set(header: "Accept", value: "application/json")
        JANetworkingConfiguration.unauthorizedRetryLimit = 1

        JANetworkingConfiguration.setLoadToken { () -> (String?) in
            // Try to store to the keychain in actual app. UserDefaults used here simply to persist data between app launches for demonstration purposes
            return UserDefaults.standard.object(forKey: "token") as? String
        }
        
        JANetworkingConfiguration.setSaveToken { (token) in
            // Try to store to the keychain in actual app. UserDefaults used here simply to persist data between app launches for demonstration purposes
            UserDefaults.standard.set(token, forKey: "token")
        }

        JANetworkingConfiguration.setUpRefreshTimer(timeInterval: 300) {
            print("Refreshing token from refresh timer trigger...")
            self.refreshToken(completion: nil)
        }
        JANetworking.delegate = self
        
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
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // MARK: - Custom Functions
    
    func refreshToken(completion:((Bool)->Void)?) {
        // Auto log user in using the user credential saved in the keychain
        // Would recommend saving the user's login info to the keychain and fetching it here
        let username = "<ENTER USERNAME HERE>"
        let password = "<ENTER PASSWORD HERE>"
        JANetworkingConfiguration.token = nil
        
        JANetworking.loadJSON(resource: User.login(username: username, password: password), completion: { (data, error) in
            if error == nil {
                print("success")
                completion?(true)
            } else {
                print("error")
                completion?(false)
            }
        })
    }
    
}



// MARK: - JANetworkDelegate Functions

extension AppDelegate:JANetworkDelegate {
    func updateToken(completion: @escaping ((Bool) -> Void)) {
        // Add any code here to handle when a users token has expired.
        print("trying to refresh")
        self.refreshToken(completion: completion)
    }
    
    func unauthorizedCallAttempted() {
        // Add any code here to handle when an authorized user is trying to make a server call.
        print("unauthorized call attempted")
    }
    
    func tokenStatusChanged() {
        NotificationCenter.default.post(name: tokenStatusNotificationName, object: nil, userInfo: nil)
    }
}

