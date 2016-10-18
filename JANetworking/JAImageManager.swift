//
//  JAThumbnailManager.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 9/26/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit

public final class JAImageManager: NSObject {
    static let sharedManager = JAImageManager()
    var library:Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    // MARK: Memory Warning
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(JAImageManager.memoryWarning), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    func memoryWarning() {
        print("JAImageManager deleting all cached images due to memory warning")
        library.removeAll(keepingCapacity: false)
    }
    
    // MARK: Local image library
    private func saveImage(image:UIImage, imageUrl:String) {
        library[imageUrl] = image
    }
    
    private func fetchImage(imageUrl:String) -> UIImage? {
        return library[imageUrl]
    }
    
    // MARK: Image file storage
    private static func writeImageToFile(imageData:Data, imageURL:String) {
        let imageDirectory = imageDirectoryPath
        do {
            // add directory if it doesn't exist
            if !(imageDirectory as NSURL).checkResourceIsReachableAndReturnError(nil) {
                try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            // save file
            try imageData.write(to: URL(fileURLWithPath: imageURL), options: .atomic)
        } catch let fileError {
            print(fileError)
        }
    }
    
    private static func localImageFileForURL(localURL:String?, type:MediaType) -> UIImage? {
        let checkImage = FileManager.default
        if let localURL = localURL , checkImage.fileExists(atPath: localURL) && JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
            var image:UIImage?
            switch type {
            case .image:
                image = UIImage(contentsOfFile: localURL)
            case .gif:
                image = UIImage.gifWithURL(gifUrl: localURL)
            }
            return image
        }
        return nil
    }
    
    public static func removeImageAtUrl(url:String) -> Bool {
        if let imageURL = locationForImageAtURL(url) {
            do {
                try FileManager.default.removeItem(atPath: imageURL)
                return true
            } catch let fileError{
                print(fileError)
            }
        } else {
            // Could no parse image url
            return false
        }
        
        return false
    }
    
    public static func removeAllCachedImages() -> Bool {
        do {
            try FileManager.default.removeItem(at: imageDirectoryPath)
            return true
        } catch let fileError {
            print(fileError)
        }
        return false
    }
    
    private static func locationForImageAtURL(_ url:String) -> String? {
        let imageDirectory = imageDirectoryPath
        var saveName = url
        saveName = saveName.replacingOccurrences(of: "/", with: "")
        let imageURL = imageDirectory.appendingPathComponent("\(saveName)").path
        
        return imageURL
    }
    
    private static var imageDirectoryPath:URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDirectory = documentsURL.appendingPathComponent("image_cache")
        return imageDirectory
    }
    
    // MARK: Server calls for images
    
    private static func fetchImageDataWithURL(imageURL:String, completion:@escaping (Data?, JANetworkingError?) -> ()) {
        URLSession.shared.dataTask(with: URL(string: imageURL)!, completionHandler: { (data, response, error) in
            if let errorObj = error {
                let networkError = JANetworkingError(error: errorObj as Error)
                completion(nil, networkError)
            }else{
                // Success request, HOWEVER the reponse can be with status code 400 and up (Errors)
                // Ensure that there is no error in the reponse and in the server
                let networkError = JANetworkingError(responseError: response, serverError: JANetworkingError.parseServerError(data: data))
                completion(data, networkError)
            }
        }).resume()
    }
    
    // MARK: - Main Methods
    
    public static func loadImage(url: String, asyncCompletion:@escaping (UIImage?, JANetworkingError?) -> ()) -> UIImage? {
        return JAImageManager.sharedManager.imageForUrl(imageUrl: url, asyncCompletion: asyncCompletion)
    }
    
    public static func loadGIF(url: String, completion:@escaping (UIImage?, JANetworkingError?) -> ()) {
        JAImageManager.loadImageMedia(url: url, type: .gif, completion: completion)
    }
    
    // Main method called from apps to access image files
    private func imageForUrl(imageUrl:String, asyncCompletion:@escaping ((UIImage?, JANetworkingError?)->Void)) -> UIImage? {
        if let image = JAImageManager.sharedManager.fetchImage(imageUrl: imageUrl) {
            return image
        } else {
            JAImageManager.loadImageMedia(url: imageUrl, type: .image) {[unowned self] (image, error) in
                if let err = error {
                    print("`JANetworking Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                    print("`JANetworking Load.image` - ERROR: \(err.errorData)")
                    asyncCompletion(nil, err)
                } else {
                    if let img = image {
                        self.saveImage(image: img, imageUrl: imageUrl)
                        asyncCompletion(img, nil)
                    } else {
                        asyncCompletion(nil, nil)
                    }
                }
            }
        }
        return nil
    }
    
    // Method called when image not accessible in local memory library
    static func loadImageMedia(url: String, type:MediaType, completion:@escaping (UIImage?, JANetworkingError?) -> ()){
        // Check local disk for image
        DispatchQueue.global(qos: .background).async {
            let localURL = locationForImageAtURL(url)
            if let image = localImageFileForURL(localURL: localURL, type: type) {
                DispatchQueue.main.async(execute: {
                    completion(image, nil)
                })
            } else {
                JAImageManager.fetchImageDataWithURL(imageURL: url, completion: { (imageData:Data?, error:JANetworkingError?) in
                    var image:UIImage?
                    if let localURL  = localURL, let imageData = imageData {
                        switch type {
                        case .image:
                            image = UIImage(data: imageData)
                        case .gif:
                            image = UIImage.gifWithData(data: imageData)
                        }
                        if let _ = image , JANetworkingConfiguration.sharedConfiguration.automaticallySaveImageToDisk {
                            JAImageManager.writeImageToFile(imageData: imageData, imageURL: localURL)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        completion(image, error)
                    })
                })
            }
        }
    }
}


// ImageView Extension for convinience use

public extension UIImageView {
    public func downloadImage(url: String, placeholder: UIImage? = nil){
        if let defaultImage = placeholder {
            image = defaultImage
        }
        image = JAImageManager.loadImage(url: url, asyncCompletion: { (image:UIImage?, error: JANetworkingError?) in
            self.image = image
        })
    }
    
    public func downloadGIF(url: String, placeholder: UIImage? = nil){
        if let defaultImage = placeholder {
            image = defaultImage
        }
        JAImageManager.loadImageMedia(url: url, type: .gif) { (image, error) in
            if let err = error {
                print("`JANetworking Load.image` - ERROR: \(err.statusCode) \(err.errorType.errorTitle())")
                print("`JANetworking Load.image` - ERROR: \(err.errorData)")
            }else{
                if let img = image {
                    self.image = img
                }
            }
        }
    }
}
