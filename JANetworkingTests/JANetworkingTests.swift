//
//  JANetworkingTests.swift
//  JANetworkingTests
//
//  Created by Enrique on 7/5/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import XCTest
@testable import JANetworking

class JANetworkingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testServerCalls() {
        let asyncExpectation = expectation(description: "async")
        
        var count = 0
        
        let resource1 = JANetworkingResource(method: .GET, url: URL(string:"www.google.com")!, headers: nil, params: nil, parseJSON: { json in
            return true
        })
        let resource2 = JANetworkingResource(method: .GET, url: URL(string:"https://www.google")!, headers: nil, params: nil, parseJSON: { json in
            return true
        })
        let resource3 = JANetworkingResource(method: .GET, url: URL(string:"https://www.google.com")!, headers: nil, params: nil, parseJSON: { json in
            return true
        })
        
        JANetworking.loadJSON(resource: resource1) { (result, error) in
            // URL should fail
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            count += 1
            if count >= 3 {
                asyncExpectation.fulfill()
            }
        }
        JANetworking.loadJSON(resource: resource2) { (result, error) in
            // URL should fail
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            count += 1
            if count >= 3 {
                asyncExpectation.fulfill()
            }
        }
        JANetworking.loadJSON(resource: resource3) { (result, error) in
            // URL should be valid and work as normal
            XCTAssertTrue(result!)
            XCTAssertNil(error)
            count += 1
            if count >= 3 {
                asyncExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testInvalidNextPage() {
        let asyncExpectation = expectation(description: "async")
        
        let resource = JANetworkingResource(method: .GET, url: URL(string:"https://www.google.com")!, headers: nil, params: nil, parseJSON: { json in
            //
        })
        let nextAvailable = JANetworking.isNextPageAvailable(for: resource)
        XCTAssertTrue(nextAvailable)  // Should always return true on first attempt
        
        JANetworking.loadPagedJSON(resource: resource) { (result, error) in
            let nextAvailableAfterLoad = JANetworking.isNextPageAvailable(for: resource)
            XCTAssertFalse(nextAvailableAfterLoad)  // Now that the resource has been loaded and the resource isn't paged, this should always return false
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Run code below once you've added a custom paged URL to the resource
//        func testValidNextPage() {
//            let asyncExpectation = expectation(description: "async")
//    
//            let resource = JANetworkingResource<String>(method: .GET, url: URL(string:"<CUSTOM PAGED URL>")!, headers: nil, params: nil, parseJSON: { json in
//                return (json as! JSONDictionary).debugDescription
//            })
//            let nextAvailable = JANetworking.isNextPageAvailable(for: resource)
//            XCTAssertTrue(nextAvailable)  // Should always return true on first attempt
//    
//            JANetworking.loadPagedJSON(resource: resource) { (result, error) in
//                let nextAvailableAfterLoad = JANetworking.isNextPageAvailable(for: resource)
//                XCTAssertTrue(nextAvailableAfterLoad)  // Now that the resource has been loaded once, this will check to see if page 2 of the paged resource exists.
//                let firstResult = result
//    
//                JANetworking.loadPagedJSON(resource: resource) { (result, error) in
//                    XCTAssertNotEqual(firstResult, result)  // Make sure the paged call is actually returning different info for page 1 and page 2
//    
//                    JANetworking.loadPagedJSON(resource: resource, pageLimit: 1, completion: { (result, error) in
//                        let nextAvailableAfterLoad = JANetworking.isNextPageAvailable(for: resource)
//                        XCTAssertFalse(nextAvailableAfterLoad)  // Since we set a page limit that's below what we've already pulled from the server, this should always fail.
//                        asyncExpectation.fulfill()
//                    })
//    
//                }
//    
//            }
//    
//            waitForExpectations(timeout: 60) { error in
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
//            }
//        }
    
}
