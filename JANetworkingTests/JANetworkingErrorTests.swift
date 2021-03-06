//
//  JANetworkingErrorTests.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 6/19/17.
//  Copyright © 2017 JAKT. All rights reserved.
//

import XCTest
@testable import JANetworking

class JANetworkingErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJANetworkingError(){
        let error1 = JANetworkingError(errorType: .unauthorized, statusCode: 401, errorData: nil)
        XCTAssertNotNil(error1)
        XCTAssertNotNil(error1.errorType)
        XCTAssertEqual(error1.errorType, ErrorType.unauthorized)
        XCTAssertEqual(error1.statusCode, 401)
        XCTAssertEqual(error1.errorType.errorTitle(), "Access Denied")
        
        let error2 = JANetworkingError(errorType: .unknown, statusCode: nil, errorData: nil)
        XCTAssertNotNil(error2)
        XCTAssertNotNil(error2.errorType)
        XCTAssertEqual(error2.errorType, ErrorType .unknown)
        XCTAssertEqual(error2.errorType.errorTitle(), "Unknown")
        XCTAssertNil(error2.statusCode)
        
        let error3 = JANetworkingError(error: NSError(domain: "somedomain", code: 1, userInfo: nil))
        XCTAssertNotNil(error3)
        XCTAssertNotNil(error3.errorType)
        XCTAssertEqual(error3.errorType, ErrorType.nsurlError)
        XCTAssertEqual(error3.errorType.errorTitle(), "NSURLError")
        XCTAssertNil(error3.statusCode)
        XCTAssertNotNil(error3.errorData)
        
        let error4 = JANetworkingError(responseError: HTTPURLResponse(url: URL(string:"somedomain")!, statusCode: 200, httpVersion: nil, headerFields: nil), serverError: nil)
        XCTAssertNil(error4)
        
        let error5 = JANetworkingError(responseError: HTTPURLResponse(url: URL(string:"somedomain")!, statusCode: 400, httpVersion: nil, headerFields: nil), serverError: nil)
        XCTAssertNotNil(error5)
        XCTAssertNotNil(error5!.errorType)
        XCTAssertEqual(error5!.errorType, ErrorType.badRequest)
        XCTAssertNotNil(error5!.errorType.errorTitle(), "Bad Request")
        XCTAssertEqual(error5!.statusCode, 400)
        XCTAssertNil(error5!.errorData)
        
        let error6 = JANetworkingError(responseError: HTTPURLResponse(url: URL(string:"somedomain")!, statusCode: 405, httpVersion: nil, headerFields: nil), serverError: [JAError(field: nil, message:"Some error")])
        XCTAssertNotNil(error6!.errorType)
        XCTAssertEqual(error6!.errorType, ErrorType.methodNotAllowed)
        XCTAssertEqual(error6!.statusCode, 405)
        XCTAssertEqual(error6!.errorType.errorTitle(), "Method Not Allowed")
        XCTAssertNotNil(error6!.errorData!)
        XCTAssertNotNil(error6!.errorData!.first?.message, "Some error")
    }
    
}
