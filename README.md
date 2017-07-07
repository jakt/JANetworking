
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Language: Swift 3](https://img.shields.io/badge/language-swift%203-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)

JANetworking is the JAKT internal networking library for Swift iOS projects.


## Installation
JANetworking is designed to be installed using Carthage.

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate JANetowrking into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "jakt/JANetworking.git"
```

Run `carthage` to build the framework and drag the built `JANetworking.framework` into your Xcode project.

## Requirements

| JANetworking Version | Minimum iOS Target |
|:--------------------:|:---------------------------:|
| 1.x | iOS 8 |

---

## Usage
Much of the JANetworking integration will be in the object's own code.  
For our example we'll use a model type called `Post`.

### Models
```
struct Post {
    let id: Int
    var title: String
    var body: String
    let authorId: String
}
```
Extend this struct model to add an init method so that the default init wont be overridden:
```
extension Post {
    init?(dictionary: [String: Any?]){
        guard let id = dictionary["id"] as? Int,
            let title = dictionary["title"] as? String,
            let body = dictionary["body"] as? String,
            let authorId = dictionary["author_id"] as? String else { return nil }
        
        self.id = id
        self.title = title
        self.body = body
        self.authorId = authorId
    }
}
```

We can now add all server calls to the `Post` object. For our example, we've created 2 endpoints:  
- `Post.all`: Fetches all the post objects from the server. This function is `static` so that it can be use without instantiating the object.   
- `Post.submit`: Creates a post object on the server. This does not need to be `static` because it requires the object itself to pull the required info.
```
    ....
    
    /// Fetch all posts
    public static func all() -> JANetworkingResource<[Post]> {
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts")!
        return JANetworkingResource(method: .GET, url: url, headers: nil, params: nil, parseJSON: { json in
            guard let items = json as? [JSONDictionary] else { return nil }
            let posts = items.flatMap(Post.init)
            return posts
        })
    }
    
    // Submit a post
    public func submit() -> JANetworkingResource<Post>{
        let url = URL(string: JANetworkingConfiguration.baseURL + "/posts")!
        let params:JSONDictionary = ["id": id,
                                     "author": authorId,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .POST, url: url, headers: nil, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return Post(json: dictionary)
        })
    }
```
All methods must return a resource generic object type.
### JANetworking
`JANetworking.loadJSON` takes in a resource generic type and a completion block. Using `JANetworking.loadJSON` will automatically detect the **[JANetworkingError](/JANetworking/JANetworkingError.swift)**  from our stack.

Finally on your `ViewController`. You can call:  
#### Get All Posts
```
JANetworking.loadJSON(Post.all()) { data, error in
    if let err = error {
        print("`Post.all` - NETWORK ERROR: \(err.errorType.errorTitle())")
    } else if let data = data {
        print("`Post.all` - SUCCESS: \(data)")
    }
}
```
#### Create a Post
```
let post = Post(id: 100, title: "My Title", body: "Some Message Here.", authorId:"199")
JANetworking.loadJSON(post.submit(headers)) { data, error in
    if let err = error {
        print("`PPost.submit` - NETWORK ERROR: \(err.errorType.errorTitle())")
    } else if let data = data {
        print("`Post.submit` - SUCCESS: \(data)")
    }
}
```

### JANetworkingConfiguration
Before using JANetworking, you must first configure the library to work with your specific server. This configuration is done using the `JANetworkConfiguration` object.

There are a few settings that should be configured on app launch that will be the default settings for all server calls. Below is a list of everything that can be set:

#### Required
- `setBaseURL(development:String, staging:String, production:String)` - Set the URLs for all environments
- `set(environment:NetworkEnvironment)` - Set the current environment
- `setSaveToken(block:SaveTokenBlock)` - Customize how the token is saved
- `setLoadToken(block:LoadTokenBlock)` - Customize how the token is loaded

#### Optional
- `set(header:String, value:String?)` - Set the request headers for network requests
- `setInvalidTokenInfo(serverResponseText:[String], HTTPStatusCodes:[Int])` - Set the triggers for an invalid token. If any server call matches any of the info passed in here, it will trigger a token refresh.
- `setUnauthorizedRetryLimit(_ limit:Int)` - Set the number of times the token should attempt to refresh before the server call fails.
- `setUpRefreshTimer(timeInterval:TimeInterval)` - Set the refresh interval for the token

### JANetworkingError
If any issues arise during a server call, a `JANetworkingError` object will be created. This object includes the status code, an easily readable `errorType`, and more detailed `errorData`. Example:
```
if let err:JANetworkingError = error {
    print("NETWORK ERROR: \(err.errorType.errorTitle())")
    if let data = err.errorData, let code = err.statusCode {
        print("Status Code: \(code), Details: \(data)")
    }
}
```
Errors that can trigger the creation of a valid JANetworkingError object include an `NSError` and response errors parsed from either the `URLResponse` or the response `Data` object itself.
#### NSError
- This error occurs when `dataTaskWithRequest` returns an NSError, which is unrelated to the reponse error. This means that the request has failed.

#### Reponse Error
 - This occurs when the `dataTaskWithRequest` returns successfully, however the reponse is within the range of status code ERROR (4xx or 5xx).
 - This can also occur when the server call is successful but the JSON packet received includes an `error` key that has valid information that can be parsed.

#### JAError
JAError contains properties `JAError.field` and `JAError.message`.  
You can access this information through the JANetworkingError property `err.errorData` which returns an Array of JAError objects. 
 
