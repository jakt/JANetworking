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
            return UserDefaults.standard.object(forKey: "token") as? String
        }
        
        JANetworkingConfiguration.setSaveToken { (token) in
            UserDefaults.standard.set(token, forKey: "token")
        }
        
        JANetworkingConfiguration.setUpRefreshTimer(timeInterval: 30) {
            print("testing token...")
        }
        
        JANetworking.loadJSON(resource: Post.all(headers: nil)) { data, error in
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
        JANetworking.loadJSON(resource: post.submit(headers: nil)) { data, error in
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
        JANetworking.loadJSON(resource: post.update(headers: nil)) { data, error in
            if let err = error {
                print("`Post.update` - ERROR: \(err.statusCode) \(err.errorType.errorTitle()))")
                print("`Post.update` - ERROR: \(err.errorData)")
            }else{
                if let data = data {
                    print("`Post.update` - SUCCESS: \(data)")
                }
            }
        }
        
        JANetworking.loadJSON(resource: Post.all(headers: nil)) { data, error in
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
//        https://static.pexels.com/photos/8700/wall-animal-dog-pet.jpg
//        https://rs-exchange-staging.s3.amazonaws.com:443/asset/asset/86/15/51cd59696d975238ea37d195c540.gif
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.imageView.image = #imageLiteral(resourceName: "placeholder")
            self.imageView.setNeedsDisplay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.imageView.downloadImage(url: "https://static.pexels.com/photos/3247/nature-forest-industry-rails.jpg", placeholder: placeholder)
            }
//            imageView.downloadImage(url: "http://www.flooringvillage.co.uk/ekmps/shops/flooringvillage/images/request-a-sample--547-p.jpg", placeholder: placeholder)
        }
        
        // Normal download image
//        http://4.bp.blogspot.com/-uhjF2kC3tFc/U_r3myvwzHI/AAAAAAAACiw/tPQ2XOXFYKY/s1600/Circles-3.gif
        JAImageManager.loadGIF(url: "https://rs-exchange-staging.s3.amazonaws.com:443/asset/asset/f3fa401f-2c82-486a-876e-693bf7e21894/5331c8bbfdb44a79a95682570228ed5d.gif") { (image, error) in
//            self.imageView2.image = image
        }
        
        let url = "https://rs-exchange-dev.s3.amazonaws.com:443/asset/asset/4963b762-d5e2-4516-915a-df4b90bc652a/e89e882cf0e74f5dbd8f9445cbf18b94.pdf"
        JAImageManager.loadGenericMedia(url: url, completion: { (localpath:String?, error:JANetworkingError?) in
            if let err = error {
                print(err.statusCode)
            } else {
                print(localpath)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

