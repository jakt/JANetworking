
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

JANetworking is the JAKT internal Networking library for Swift iOS projects.


## Installation
JANetworking is designed to be installed using Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate JANetowrking into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "git@github.com:jakt/JANetworking.git" ~> 1.0
```

Run `carthage` to build the framework and drag the built `JANetworking.framework` into your Xcode project.

## Requirements

| JANetworking Version | Minimum iOS Target |
|:--------------------:|:---------------------------:|
| 1.x | iOS 9 |

---

## Usage
JANetworking usage architecture are mostly define in the model object itself.  
For example, I will be using a model type called `Post`

### Models
```
struct Post {
    let id: Int
    let userName: String
    var title: String
    var body: String
}
```

Extend this struct model to add an init method so that the original init wont get overriden
```
extension Post {
    init?(dictionary: [String: AnyObject]){
        guard let id = dictionary["id"] as? Int,
            title = dictionary["title"] as? String,
            userName = dictionary["user_name"] as? String,
            body = dictionary["body"] as? String else { return nil }
        
        self.id = id
        self.userName = userName
        self.title = title
        self.body = body
    }
}
```

Now we need to add the rest of the methods in the `Post extension` that we want for calling the server. All methods must return a resource generic object type. For my example, I have created 2 endpoints:  
`Post.all`: Fetches all the post objects from the server. Make sure this method is `static` so that it can be use without instantiating the Object.   
`Post.submit`: Creates a post object in the server. This does not need to be `static` because it requires you to instantiate the object itself in order to use it. 
```
    ....
    
    // Get all post
    static func all(headers: [String: String]?) -> JANetworkingResource<[Post]>{
        let url = NSURL(string: baseUrl + "/posts")!
        return JANetworkingResource(method: .GET, url: url, headers: headers, params: nil, parseJSON: { json in
            guard let dictionaries = json as? [JSONDictionary] else { return nil }
            return dictionaries.flatMap(Post.init)
        })
    }
    
    // Submit a post
    func submit(headers: [String: String]?) -> JANetworkingResource<Post>{
        let url = NSURL(string: baseUrl + "/posts")!
        let params:JSONDictionary = ["id": id,
                                     "userName": userName,
                                     "title": title,
                                     "body": body]
        return JANetworkingResource(method: .POST, url: url, headers: headers, params: params, parseJSON: { json in
            guard let dictionary = json as? JSONDictionary else { return nil }
            return Post(dictionary: dictionary)
        })
    }
```
### JANetworking
`JANetworking.loadJSON` takes in resource generic type and a completion block. Using `JANetworking.loadJSON` will automatically detect the **[JANetworkingError](#JANetworkingError)**  from our stack

Finally on your `ViewController`. You can call:  
#### Get All Post
```
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
```
#### Create a Post
```
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
```
### JANetworkingError
There are 2 types of error: NSError, Response Error. You can access to the error data in the JANetworkingError object. `JANetworkingError.errorData`. Example:
```
if let err = error {
    print("`Post.submit` - ERROR: \(err.statusCode) - \(err.errorType.errorTitle())")
    print("`Post.submit` - ERROR: \(err.errorType.errorDescription())")
    print("`Post.submit` - ERROR: \(err.errorData)")
}
```
#### NSError
- This error occurs when `dataTaskWithRequest` returns an NSError, which is unrelated to the reponse error. This means that the request has failed.

#### Reponse Error
 - This occurs when the `dataTaskWithRequest` returns success, However the reponse is within the range of status code ERROR (4xx or 5xx). Dependeding on the error the `error` field can vary. Usually it will be in this format: 
```
{
    "error_type": "MethodNotAllowed",
    "errors":[{
         "message": "Method Get not allowed",
    }]
}
```