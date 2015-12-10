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
    
    private let request = CascadeAPI.Snoqualmie.request

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
        
        let success: Success = {
            expectation.fulfill()
        }
        
        let failure: Failure = {
            XCTFail("Request should not fail")
        }
        
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(LocalURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        networkController.executeNetworkRequest(request, success: success, failure: failure)
        
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    
    func testCanHandleBadStatusCode() {
        let expectation = expectationWithDescription("Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expectation.fulfill()
        }
        
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(BadStatusURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        networkController.executeNetworkRequest(request, success: success, failure: failure)
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    
    func testCanHandleBadResponse() {
        let expectation = expectationWithDescription("Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expectation.fulfill()
        }
        
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(BadResponseURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        networkController.executeNetworkRequest(request, success: success, failure: failure)
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    
    func testCanHandleBadURL() {
        let expectation = expectationWithDescription("Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expectation.fulfill()
        }
        
        let configuration = NSURLSessionConfiguration.configurationWithProtocol(FailingURLProtocol)
        let networkController = NetworkController(configuration: configuration)
        
        networkController.executeNetworkRequest(request, success: success, failure: failure)
        waitForExpectationsWithTimeout(15.0, handler: nil)
    }
}

typealias Success = Void -> ()
typealias Failure = Void -> ()

extension NetworkController {
    func executeNetworkRequest(request: NSURLRequest, success: Success, failure: Failure) {
        self.dataForRequest(request).start { (result) -> () in
            switch result {
            case .Success:
                success()
            case .Failure:
                failure()
            }
        }
    }
}
