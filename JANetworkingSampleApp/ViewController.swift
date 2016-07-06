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
        
        // USAGE
        JANetworking.loadJSON(Post.all) { data, error in
            if let err = error {
                print("ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
                print("ERROR: \(err.errorType.errorMessage())")
            }else{
                if let data = data {
                    print("SUCCESS: \(data)")
                }
            }
        }
        
        JANetworking.loadJSON(Post.submit) { data, error in
            if let err = error {
                print("ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
                print("ERROR: \(err.errorType.errorMessage())")
            }else{
                if let data = data {
                    print("SUCCESS: \(data)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

