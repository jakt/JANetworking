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
        // Do any additional setup after loading the view, typically from a nib.
        
        ///////////////////////////////////////////////////////////////////////////
        // USAGE
        ///////////////////////////////////////////////////////////////////////////
        
        // Get all posts
        
        JANetworkingConfiguration.setLoadToken { () -> (String?) in
            return NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        }
        
        JANetworkingConfiguration.setSaveToken { (token) in
            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
        }
        
        JANetworkingConfiguration.setUpRefreshTimer(2) {
            print("testing token...")
        }
        
        JANetworking.loadJSON(Post.all(nil)) { data, error in
            if let err = error {
                print("`Post.all` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                print("`Post.all` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.all` - SUCCESS: \(data)")
                }
            }
        }
        
        // Create a Post object
        var post = Post(id: 100, userName: "Enrique W", title: "My Title", body: "Some Message Here.")
        JANetworking.loadJSON(post.submit(nil)) { data, error in
            if let err = error {
                print("`Post.submit` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
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
        JANetworking.loadJSON(post.update(nil)) { data, error in
            if let err = error {
                print("`Post.update` - ERROR: \(err.statusCode) \(err.errorType.errorTitle()))")
                print("`Post.update` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.update` - SUCCESS: \(data)")
                }
            }
        }
        
        JANetworking.loadJSON(Post.all(nil)) { data, error in
            if let err = error {
                print("`Post.all` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                print("`Post.all` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.all` - SUCCESS: \(data)")
                }
            }
        }
        
        // Download image with imageview extension
        let placeholder = UIImage(named: "placeholder")
//        https://www.clicktorelease.com/code/gif/1.gif
        imageView.downloadGIF("https://www.clicktorelease.com/code/gif/1.gif", placeholder: placeholder)
//        imageView.downloadImage("http://www.flooringvillage.co.uk/ekmps/shops/flooringvillage/images/request-a-sample--547-p.jpg", placeholder: placeholder)
        
        // Normal download image
//        http://4.bp.blogspot.com/-uhjF2kC3tFc/U_r3myvwzHI/AAAAAAAACiw/tPQ2XOXFYKY/s1600/Circles-3.gif
        JANetworking.loadImageMedia("http://4.bp.blogspot.com/-uhjF2kC3tFc/U_r3myvwzHI/AAAAAAAACiw/tPQ2XOXFYKY/s1600/Circles-3.gif", type: MediaType.GIF) { (image, error) in
//        JANetworking.loadImage("https://www.ricoh.com/r_dc/cx/cx1/img/sample_04.jpg") { (image, error) in
            if let err = error {
                print("`Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                print("`Load.image` - ERROR: \(err.errorData)")
            }else{
                if let img = image {
                    print("`Load.image` - SUCCESS: \(img)")
                    self.imageView2.image = img
                }
            }
        }
//        JANetworking.removeAllImages()
//        JANetworking.removeImageAtUrl("http://www.flooringvillage.co.uk/ekmps/shops/flooringvillage/images/request-a-sample--547-p.jpg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

