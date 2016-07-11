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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ///////////////////////////////////////////////////////////////////////////
        // USAGE
        ///////////////////////////////////////////////////////////////////////////
        
        // Get all posts
        let headers = ["Authorization": "SomeTokenValue"] // Add header example
        JANetworking.loadJSON(Post.all(headers)) { data, error in
            if let err = error {
                print("`Post.all` - ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
                print("`Post.all` - ERROR: \(err.errorType.errorDescription())")
                print("`Post.all` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.all` - SUCCESS: \(data)")
                }
            }
        }
        
        // Create a Post object
        var post = Post(id: 100, userName: "Enrique W", title: "My Title", body: "Some Message Here.")
        JANetworking.loadJSON(post.submit(headers)) { data, error in
            if let err = error {
                print("`Post.submit` - ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
                print("`Post.submit` - ERROR: \(err.errorType.errorDescription())")
                print("`Post.submit` - ERROR: \(err.errorData)")

            }else{
                if let data = data {
                    print("`Post.submit` - SUCCESS: \(data)")
                }
            }
        }
        
        // Update a post
        // ERROR endpoint, should return 405. I set it this way to test
        post.title = "Random"
        JANetworking.loadJSON(post.update(headers)) { data, error in
            if let err = error {
                print("`Post.update` - ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
                print("`Post.update` - ERROR: \(err.errorType.errorDescription())")
                print("`Post.update` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.update` - SUCCESS: \(data)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

