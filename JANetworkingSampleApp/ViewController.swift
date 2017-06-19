//
//  ViewController.swift
//  JANetworkingSampleApp
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit
import JANetworking

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageView2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all posts
        JANetworking.loadJSON(resource: PostTest.all(headers: nil)) { data, error in
            if let err = error {
                print("`PostTest.all` - ERROR: \(err.statusCode ?? 0) \(err.errorType.errorTitle())")
                if let data = err.errorData { print("`PostTest.all` - ERROR: \(data)") }
            }else{
                if let data = data {
                    print("`PostTest.all` - SUCCESS: \(data)")
                }
            }
        }
        
        // Create a PostTest object
        var post = PostTest(id: 100, userName: "Enrique W", title: "My Title", body: "Some Message Here.")
        JANetworking.loadJSON(resource: post.submit(headers: nil)) { data, error in
            if let err = error {
                print("`PostTest.submit` - ERROR: \(err.statusCode ?? 0) \(err.errorType.errorTitle())")
                if let data = err.errorData { print("`PostTest.all` - ERROR: \(data)") }

            }else{
                if let data = data {
                    print("`PostTest.submit` - SUCCESS: \(data)")
                }
            }
        }
        
        // Update a post
        // ERROR endpoint, should return 405.
        post.title = "Random"
        JANetworking.loadJSON(resource: post.update(headers: nil)) { data, error in
            if let err = error {
                print("`PostTest.update` - ERROR: \(err.statusCode ?? 0) \(err.errorType.errorTitle()))")
                if let data = err.errorData { print("`PostTest.all` - ERROR: \(data)") }
            }else{
                if let data = data {
                    print("`PostTest.update` - SUCCESS: \(data)")
                }
            }
        }
        
        JANetworking.loadJSON(resource: PostTest.all(headers: nil)) { data, error in
            if let err = error {
                print("`PostTest.all` - ERROR: \(err.statusCode ?? 0) \(err.errorType.errorTitle())")
                if let data = err.errorData { print("`PostTest.all` - ERROR: \(data)") }
            }else{
                if let data = data {
                    print("`PostTest.all` - SUCCESS: \(data)")
                }
            }
        }
        
        // Download image with imageview extension
        let placeholder = UIImage(named: "placeholder")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.imageView.image = #imageLiteral(resourceName: "placeholder")
            self.imageView.setNeedsDisplay()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.imageView.downloadImage(url: "https://static.pexels.com/photos/3247/nature-forest-industry-rails.jpg", placeholder: placeholder)
//            }
        }
        
        // Normal download image
        JAImageManager.loadGIF(url: "http://4.bp.blogspot.com/-uhjF2kC3tFc/U_r3myvwzHI/AAAAAAAACiw/tPQ2XOXFYKY/s1600/Circles-3.gif") { (image, error) in
            self.imageView2.image = image
        }
        
        let url = "https://rs-exchange-dev.s3.amazonaws.com:443/asset/asset/4963b762-d5e2-4516-915a-df4b90bc652a/e89e882cf0e74f5dbd8f9445cbf18b94.pdf"
        JAImageManager.loadGenericMedia(url: url, completion: { (localpath:String?, error:JANetworkingError?) in
            if let err = error {
                print(err.statusCode ?? 0)
            } else {
                print(localpath ?? "No local path")
            }
        })
    }
    
    // Test loading a resource
    func testPosts() {
        // FOR TESTING, SET THE TOKEN TO AN OLD, INVALID TOKEN AND SEE IF JANETWORKING REFRESHES THE TOKEN CORRECTLY
        JANetworkingConfiguration.token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYjNlN2RmNGUtY2E0My00YTk5LTk3OWQtNGI5MWNkOGVhNzc3IiwiZW1haWwiOiJ1QHUuY29tIiwiZXhwIjoxNDc4MjA4MjU4LCJ1c2VybmFtZSI6InVAdS5jb20iLCJvcmlnX2lhdCI6MTQ3ODIwNzM4M30.3XTUV7T2LzpyR4LVy5Kv--ICXfIjN4hvAV-apBNOUqo"
        
//        let singelResource = Post.postWithId("<UNIQUE IDENTIFIER>")
        let arrayResource = Post.all()
        loadPage(for: arrayResource)
    }
    
    func loadPage<A>(for resource:JANetworkingResource<A>) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

