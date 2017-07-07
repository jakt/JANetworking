
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Language: Swift 3](https://img.shields.io/badge/language-swift%203-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)

JANetworking is a networking library that handles both secure token management and clean server response parsing. Simple API calls can be completely set up, parsed, and returned within the code of an object itself, or an adapter. On every server call, the token is updated, saved, and used only once on the very next call, creating a secure connection to the server. With little setup, this library can fully track and refresh that token without you needing to track it yourself.

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
Much of the JANetworking integration will be in the code of the objects themselves.  

Let's take a look at how to use JANetworking with a simple object `Post`:

```
struct Post {
    let id: Int
    var title: String
    var body: String
    let authorId: String
}
```

With this library we can simply configure all server calls in the `Post` object. For our example, we've created 2 endpoints:  
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
    
    /// Submit a post
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
### Making Server Calls
Use `JANetworking.loadJSON` to actually make your server calls. This function takes in a resource generic type and a completion block and returns you the object type defined in your resource.

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
JANetworking.loadJSON(post.submit()) { data, error in
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
- `setBaseURL(development:String, staging:String, production:String)` - Set the URLs for all environments.
- `set(environment:NetworkEnvironment)` - Set the current environment.
- `setSaveToken(block:SaveTokenBlock)` - Customize how the token is saved. Usually this is a simple keychain store one liner.
- `setLoadToken(block:LoadTokenBlock)` - Customize how the token is loaded. Usually this is a simple keychain fetch.

#### Optional
- `set(header:String, value:String?)` - Set the default request headers for all network requests.
- `setInvalidTokenInfo(serverResponseText:[String], HTTPStatusCodes:[Int])` - Set the triggers for an invalid token. If any server call matches any of the info passed in here, it will trigger a token refresh.
- `setUnauthorizedRetryLimit(_ limit:Int)` - Set the number of times the token should attempt to refresh before the server is counted as unsuccesful.
- `setUpRefreshTimer(timeInterval:TimeInterval)` - Set the refresh interval for the token.

### JANetworkingError
If `JANetworking.loadJSON` automatically detects any errors, a **[JANetworkingError](/JANetworking/JANetworkingError.swift)** object will be created. This object includes the status code, an easily readable `errorType`, and more detailed `errorData`. Example:
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
 
