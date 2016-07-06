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
    
    func testJANetworkingResource(){
        let res = JANetworkingResource(method: .GET, url: NSURL(string: "www.google.com")!, headers: nil, params: nil, parseJSON: { json in
            print("Callback parseJSON")
        })
        
        XCTAssertNotNil(res.method)
        XCTAssertNotNil(res.url)

        XCTAssertNil(res.headers)
        XCTAssertNil(res.params)
    }
    
    func testJANetworkingError(){
        let error1 = JANetworkingError(errorType: .Unauthorized, error: nil, statusCode: 401)
        XCTAssertNotNil(error1)
        XCTAssertNotNil(error1.errorType)
        XCTAssertEqual(error1.statusCode, 401)
        XCTAssertEqual(error1.errorType.errorTitle(), "Access Denied")
        XCTAssertEqual(error1.errorType.errorMessage(), "Authentication is needed to get requested response. This is similar to 403, but in this case, authentication is possible.")
        
        let error2 = JANetworkingError(errorType: .Unknown, error: nil, statusCode: nil)
        XCTAssertNotNil(error2)
        XCTAssertNotNil(error2.errorType)
        XCTAssertEqual(error2.errorType.errorTitle(), "Unknown")
        XCTAssertEqual(error2.errorType.errorMessage(), "Sorry. Unexpected error.")
        XCTAssertNil(error2.error)
        XCTAssertNil(error2.statusCode)
        
        let error3 = JANetworkingError(error: NSError(domain: "somedomain", code: 123, userInfo: nil))
        XCTAssertNotNil(error3)
        XCTAssertNotNil(error3.error)
        XCTAssertNotNil(error3.errorType)
        XCTAssertNotNil(error3.errorType.errorTitle(), "Unknown")
        XCTAssertEqual(error3.errorType.errorMessage(), "Sorry. Unexpected error.")
        
        let error4 = JANetworkingError(response: NSHTTPURLResponse(URL: NSURL(string:"somedomain")!, statusCode: 200, HTTPVersion: nil, headerFields: nil))
        XCTAssertNil(error4)


        let error5 = JANetworkingError(response: NSHTTPURLResponse(URL: NSURL(string:"somedomain")!, statusCode: 400, HTTPVersion: nil, headerFields: nil))
        XCTAssertNotNil(error5)
        XCTAssertNil(error5!.error)
        XCTAssertNotNil(error5!.errorType)
        XCTAssertNotNil(error5!.errorType.errorTitle(), "Bad Request")
        XCTAssertEqual(error5!.errorType.errorMessage(), "This response means that server could not understand the request due to invalid syntax.")
    }
}
