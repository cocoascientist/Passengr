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

@testable import Passengr

class NetworkControllerTests: XCTestCase {
    
    private lazy var request: URLRequest = {
        guard let url = URL(string: CascadePass.Snoqualmie.path) else { fatalError() }
        let request = URLRequest(url: url)
        return request
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanRequestPassSuccessfully() {
        let expected = expectation(description: "Request should be successful")
        
        let success: Success = {
            expected.fulfill()
        }
        
        let failure: Failure = {
            XCTFail("Request should not fail")
        }
        
        let configuration = URLSessionConfiguration.configurationWithProtocol(LocalURLProtocol.self)
        let networkController = NetworkController(with: configuration)
        
        networkController.execute(request: request, success: success, failure: failure)
        
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testCanHandleBadStatusCode() {
        let expected = expectation(description: "Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expected.fulfill()
        }
        
        let configuration = URLSessionConfiguration.configurationWithProtocol(BadStatusURLProtocol.self)
        let networkController = NetworkController(with: configuration)
        
        networkController.execute(request: request, success: success, failure: failure)
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testCanHandleBadResponse() {
        let expected = expectation(description: "Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expected.fulfill()
        }
        
        let configuration = URLSessionConfiguration.configurationWithProtocol(BadResponseURLProtocol.self)
        let networkController = NetworkController(with: configuration)
        
        networkController.execute(request: request, success: success, failure: failure)
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testCanHandleBadURL() {
        let expected = expectation(description: "Request should not be successful")
        
        let success: Success = {
            XCTFail("Request should fail")
        }
        
        let failure: Failure = {
            expected.fulfill()
        }
        
        let configuration = URLSessionConfiguration.configurationWithProtocol(FailingURLProtocol.self)
        let networkController = NetworkController(with: configuration)
        
        networkController.execute(request: request, success: success, failure: failure)
        waitForExpectations(timeout: 15.0, handler: nil)
    }
}

typealias Success = () -> ()
typealias Failure = () -> ()

extension NetworkController {
    func execute(request: URLRequest, success: @escaping Success, failure: @escaping Failure) {
        self.data(for: request).start { (result) -> () in
            switch result {
            case .success:
                success()
            case .failure:
                failure()
            }
        }
    }
}
