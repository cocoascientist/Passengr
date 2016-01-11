//
//  DataSourceTests.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import XCTest

class DataSourceTests: XCTestCase {
    
    class TestableDataSource: PassDataSource {
        let initializedModelExpectation: XCTestExpectation
        
        init(expectation: XCTestExpectation) {
            self.initializedModelExpectation = expectation
            super.init()
        }
        
        override func loadOrCreateInitialModel() {
            super.loadOrCreateInitialModel()
        }
    }
    
    let dataSource = PassDataSource()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testCanCreateDataSource() {
//        let initializedModelExpectation = expectationWithDescription("model should be initialized")
//        
//        let _ = TestableDataSource(expectation: initializedModelExpectation)
//        let _ = PassDataController(storeType: NSInMemoryStoreType)
//        
//        waitForExpectationsWithTimeout(15.0, handler: nil)
//    }
}
