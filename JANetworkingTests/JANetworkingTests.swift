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
        let error1 = JANetworkingError(errorType: .Unauthorized, statusCode: 401, errorData: nil)
        XCTAssertNotNil(error1)
        XCTAssertNotNil(error1.errorType)
        XCTAssertEqual(error1.errorType, ErrorType.Unauthorized)
        XCTAssertEqual(error1.statusCode, 401)
        XCTAssertEqual(error1.errorType.errorTitle(), "Access Denied")

        let error2 = JANetworkingError(errorType: .Unknown, statusCode: nil, errorData: nil)
        XCTAssertNotNil(error2)
        XCTAssertNotNil(error2.errorType)
        XCTAssertEqual(error2.errorType, ErrorType.Unknown)
        XCTAssertEqual(error2.errorType.errorTitle(), "Unknown")
        XCTAssertNil(error2.statusCode)
        
        let error3 = JANetworkingError(error: Error(domain: "somedomain", code: -1000, userInfo: nil))
        XCTAssertNotNil(error3)
        XCTAssertNotNil(error3.errorType)
        XCTAssertEqual(error3.errorType, ErrorType.NSURLError)
        XCTAssertEqual(error3.errorType.errorTitle(), "NSURLError")
        XCTAssertNil(error3.statusCode)
        XCTAssertNotNil(error3.errorData)

        let error4 = JANetworkingError(responseError: NSHTTPURLResponse(URL: NSURL(string:"somedomain")!, statusCode: 200, HTTPVersion: nil, headerFields: nil), serverError: nil)
        XCTAssertNil(error4)

        let error5 = JANetworkingError(responseError: NSHTTPURLResponse(URL: NSURL(string:"somedomain")!, statusCode: 400, HTTPVersion: nil, headerFields: nil), serverError: nil)
        XCTAssertNotNil(error5)
        XCTAssertNotNil(error5!.errorType)
        XCTAssertEqual(error5!.errorType, ErrorType.BadRequest)
        XCTAssertNotNil(error5!.errorType.errorTitle(), "Bad Request")
        XCTAssertEqual(error5!.statusCode, 400)
        XCTAssertNil(error5!.errorData)

        let error6 = JANetworkingError(responseError: NSHTTPURLResponse(URL: NSURL(string:"somedomain")!, statusCode: 405, HTTPVersion: nil, headerFields: nil), serverError: [JAError(field: nil, message:"Some error")])
        XCTAssertNotNil(error6!.errorType)
        XCTAssertEqual(error6!.errorType, ErrorType.MethodNotAllowed)
        XCTAssertEqual(error6!.statusCode, 405)
        XCTAssertEqual(error6!.errorType.errorTitle(), "Method Not Allowed")
        XCTAssertNotNil(error6!.errorData!)
        XCTAssertNotNil(error6!.errorData!.first?.message, "Some error")
    }
}
