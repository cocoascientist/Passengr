//
//  NetworkControllerTests.swift
//  Passengr
//
//  Created by Andrew Shepard on 4/14/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class NetworkControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanRequestPassSuccessfully() {
        let expectation = expectationWithDescription("Request should be successful")
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(LocalURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        let request = CascadeAPI.Snoqualmie.request
        
        networkController.dataForRequest(request).start { (result) -> () in
            switch result {
            case .Success:
                expectation.fulfill()
            case .Failure:
                XCTFail("Request should not fail")
            }
        }
        
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    
    func testCanHandleBadStatusCode() {
        let expectation = expectationWithDescription("Request should not be successful")
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(BadStatusURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        let request = CascadeAPI.Snoqualmie.request
        
        networkController.dataForRequest(request).start { (result) -> () in
            switch result {
            case .Success:
                XCTFail("Request should fail")
            case .Failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
}
