//
//  JANetworkingConfigurationTests.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 6/19/17.
//  Copyright © 2017 JAKT. All rights reserved.
//

import XCTest
@testable import JANetworking

class JANetworkingConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURLS() {
        JANetworkingConfiguration.setBaseURL(development: "dev", staging: "staging", production: "prod")
        
        JANetworkingConfiguration.set(environment: .development)
        XCTAssertEqual(JANetworkingConfiguration.baseURL, "dev")
        XCTAssertEqual(JANetworkingConfiguration.sharedConfiguration.currentEnvironment, .development)
        
        JANetworkingConfiguration.set(environment: .staging)
        XCTAssertEqual(JANetworkingConfiguration.baseURL, "staging")
        XCTAssertEqual(JANetworkingConfiguration.sharedConfiguration.currentEnvironment, .staging)
        
        JANetworkingConfiguration.set(environment: .production)
        XCTAssertEqual(JANetworkingConfiguration.baseURL, "prod")
        XCTAssertEqual(JANetworkingConfiguration.sharedConfiguration.currentEnvironment, .production)
    }
    
    func testHeaders() {
        XCTAssertEqual(0, JANetworkingConfiguration.sharedConfiguration.configurationHeaders.count)
        
        JANetworkingConfiguration.set(header: "one", value: "1")
        JANetworkingConfiguration.set(header: "two", value: "2")
        JANetworkingConfiguration.set(header: "three", value: "3")
        
        XCTAssertEqual("1", JANetworkingConfiguration.sharedConfiguration.configurationHeaders["one"])
        XCTAssertEqual("2", JANetworkingConfiguration.sharedConfiguration.configurationHeaders["two"])
        XCTAssertEqual("3", JANetworkingConfiguration.sharedConfiguration.configurationHeaders["three"])
    }
 
    func testTimer () {
        let asyncExpectation = expectation(description: "async")

        let start = Date()
        var resetStart = Date()
        JANetworkingConfiguration.setUpRefreshTimer(timeInterval: 5.0) {
            let interval = -start.timeIntervalSinceNow
            let resetInterval = -resetStart.timeIntervalSinceNow
            XCTAssertLessThan(interval, 8.1)
            XCTAssertGreaterThan(interval, 7.9)
            XCTAssertLessThan(resetInterval, 5.1)
            XCTAssertGreaterThan(resetInterval, 4.9)
            
            asyncExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            // Resets the timer after 3 seconds. This will cause the refresh timer block to be delay for another 3 seconds before triggering.
            JANetworkingConfiguration.resetRefreshTimer()
            resetStart = Date()
        })
        
        waitForExpectations(timeout: 60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
