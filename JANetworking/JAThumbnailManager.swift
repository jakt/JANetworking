//
//  JAThumbnailManager.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 9/26/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit

class JAThumbnailManager: NSObject {
    static let sharedManager = JAThumbnailManager()
    var library:Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    func saveImage(image:UIImage, imageUrl:String) {
        library[imageUrl] = image
    }
    
    func fetchImage(imageUrl:String) -> UIImage? {
        return library[imageUrl]
    }
    
    func thumbnailForUrl(thumbnailUrl:String?, completion:((UIImage)->Void)) {
        if let thumbnail = thumbnailUrl {
            if let thumbnailImage = JAThumbnailManager.sharedManager.fetchImage(thumbnail) {
                completion(thumbnailImage)
            } else {
                JANetworking.loadImageMedia(thumbnail, type: .Image) {[unowned self] (image, error) in
                    if let err = error {
                        print("`JANetworking Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                        print("`JANetworking Load.image` - ERROR: \(err.errorData)")
                    }else{
                        if let img = image {
                            self.saveImage(img, imageUrl: thumbnail)
                            completion(img)
                        }
                    }
                }
            }
        }
    }
    
    func memoryWarning() {
        library.removeAll()
    }
}
