//
//  JANetworkingResourceTests.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 6/19/17.
//  Copyright © 2017 JAKT. All rights reserved.
//

import XCTest
@testable import JANetworking

class JANetworkingResourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJANetworkingResource(){
        let resourse1 = JANetworkingResource<String>(method: .GET, url: URL(string: "https://www.google.com")!, headers: nil, params: nil, parseJSON: { json in
            return "test"
        })
        
        XCTAssertEqual(resourse1.url.absoluteString, "https://www.google.com")
        XCTAssertEqual(resourse1.method, RequestMethod.GET)
        XCTAssertNil(resourse1.headers)
        XCTAssertNil(resourse1.params)
        
        
        let testHeaders = ["test1":"header1", "test2":"header2", "test3":"header3"]
        let testParams:JSONDictionary = ["test1":"param1", "test2":2, "test3":[3], "test4":["dictionary":4]]
        let resourse2 = JANetworkingResource<String>(method: .GET, url: URL(string: "https://www.wikipedia.org")!, headers: testHeaders, params: testParams, parseJSON: { json in
            return "test"
        })
        
        XCTAssertEqual(resourse2.url.absoluteString, "https://www.wikipedia.org")
        XCTAssertEqual(resourse2.method, RequestMethod.GET)
        XCTAssertEqual(resourse2.headers!, testHeaders)
        XCTAssertEqual(resourse2.params!.description, testParams.description)
        
        let asyncExpectation = expectation(description: "async")

        JANetworking.loadJSON(resource: resourse1) { (result, error) in
            XCTAssertEqual(result, "test")
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
