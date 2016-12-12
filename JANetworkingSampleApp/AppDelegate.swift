//
//  AppDelegate.swift
//  rs_exchange
//
//  Created by Eli Liebman on 6/28/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import JANetworking
import CoreLocation

let baseUrl = "http://demo3646012.mockable.io"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Create CoreData context
        
//        // Setup for JANetworking
        JANetworkingConfiguration.setBaseURL(development: "https://rs-exchange-dev.herokuapp.com/api", staging: "https://rs-exchange-staging.herokuapp.com/api", production: "https://rs-exchange-live.herokuapp.com/api")
        JANetworkingConfiguration.set(environment: .production)

        JANetworkingConfiguration.setLoadToken { () -> (String?) in
            return UserDefaults.standard.object(forKey: "token") as? String
        }
        
        JANetworkingConfiguration.setSaveToken { (token) in
            UserDefaults.standard.set(token, forKey: "token")
        }

        JANetworkingConfiguration.unauthorizedRetryLimit = 1
        JANetworking.delegate = self
//
//        //        refreshToken(completion:nil)
//        
//        // FOR TESTING, SET THE TOKEN TO AN OLD, INVALID TOKEN AND SEE IF JANETWORKING REFRESHES THE TOKEN CORRECTLY
        JANetworkingConfiguration.token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYjNlN2RmNGUtY2E0My00YTk5LTk3OWQtNGI5MWNkOGVhNzc3IiwiZW1haWwiOiJ1QHUuY29tIiwiZXhwIjoxNDc4MjA4MjU4LCJ1c2VybmFtZSI6InVAdS5jb20iLCJvcmlnX2lhdCI6MTQ3ODIwNzM4M30.3XTUV7T2LzpyR4LVy5Kv--ICXfIjN4hvAV-apBNOUqo"
//        
//        JANetworking.loadJSON(resource: User.userDetails()) { (data, error) in
        JANetworking.loadJSON(resource: User.refreshToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJvcmlnX2lhdCI6MTQ4MDQ2MjgxOCwiZXhwIjoxNDgwNDYzNDIwLCJ1c2VybmFtZSI6ImtAay5jb20iLCJ1c2VyX2lkIjoiMGFmYThiZjUtOGU2Zi00N2JkLTgzZTYtZjYzZjNhYzA2OTMzIiwiZW1haWwiOiJrQGsuY29tIn0._2PFrWYdiJg3Q7v6x8jH9qUbGsAHYaT60zzaWV6O-Vk")) { (data, error) in
            if error == nil {
                print("success")
            } else {
                print("error")
            }
        }

        
        
        
//        //Setup for JANetworking
//        JANetworkingConfiguration.setBaseURL(development: "https://rdv-development.herokuapp.com/api", staging: "https://rdv-development.herokuapp.com/api", production: "")
//        JANetworkingConfiguration.set(environment: .development)
//        
//        JANetworkingConfiguration.unauthorizedRetryLimit = 1
//        JANetworking.delegate = self
//        
//        let location = CLLocationCoordinate2D(latitude: 41.597868744388492, longitude: -74.799476078810983)
//        let resource = Post.postOfType(.here, location:location, radius:2806104)
//        loadPage(for: resource)
        
//        let resource = Post.like(postID: "5b067af9-a345-46cd-a9f7-1f2d08ec8955")
//        let resource = Post.unlike(postID: "5b067af9-a345-46cd-a9f7-1f2d08ec8955")
//        let resource = Post.all()
//        JANetworking.loadJSON(resource: resource) { (data, error:JANetworkingError?) in
//            print(error)
//            print(data)
//            print("******")
//        }
        
        
        return true
    }
    
    func loadPage(for resource:JANetworkingResource<[Post]>) {
        JANetworking.loadPagedJSON(resource: resource, pageLimit:2) { (data, error) in
            if error == nil {
                if JANetworking.isNextPageAvailable(for: resource, pageLimit:2) {
                    self.loadPage(for: resource)
                } else {
                    print("NO PAGES LEFT")
                }
            } else {
                print("error")
            }
        }
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
        let username = "j@j.com"
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
//        JANetworkingConfiguration.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IiIsInVzZXJuYW1lIjoiKzE1MDI0NzUyNzc4IiwiZXhwIjoxNDgwMDEwMzU0LCJwaG9uZV9udW1iZXIiOiIrMTUwMjQ3NTI3NzgiLCJvcmlnX2lhdCI6MTQ3OTQwNTU1NCwidXNlcl9pZCI6IjVmZDA5ZTM0LTEzZGUtNDdlOC05ZDNlLTQ1YmM2Y2JjZGMwNyJ9.lUMhpXQZ_2ocVvYapa_9DTwCO2HX3jNtQYVM-llEMXc"
//        completion?(true)
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

