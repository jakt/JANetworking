//
//  JAThumbnailManager.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 9/26/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit

class JAImageManager: NSObject {
    static let sharedManager = JAImageManager()
    var library:Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(JAImageManager.memoryWarning), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    private func saveImage(image:UIImage, imageUrl:String) {
        library[imageUrl] = image
    }
    
    private func fetchImage(imageUrl:String) -> UIImage? {
        return library[imageUrl]
    }
    
    func imageForUrl(imageUrl:String, completion:@escaping ((UIImage?)->Void)) {
        if let image = JAImageManager.sharedManager.fetchImage(imageUrl: imageUrl) {
            completion(image)
        } else {
            JANetworking.loadImageMedia(url: imageUrl, type: .image) {[unowned self] (image, error) in
                if let err = error {
                    print("`JANetworking Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                    print("`JANetworking Load.image` - ERROR: \(err.errorData)")
                    completion(nil)
                } else {
                    if let img = image {
                        self.saveImage(image: img, imageUrl: imageUrl)
                        completion(img)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func memoryWarning() {
        print("JAImageManager deleting all cached images due to memory warning")
        library.removeAll(keepingCapacity: false)
    }
}
