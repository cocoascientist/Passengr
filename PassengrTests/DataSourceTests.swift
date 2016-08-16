//
//  DataSourceTests.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import XCTest

@testable import Passengr

class DataSourceTests: XCTestCase {
    
    class TestableDataSource: PassDataSource {
        let initializedModelExpectation: XCTestExpectation
        
        init(expectation: XCTestExpectation) {
            self.initializedModelExpectation = expectation
            super.init()
        }
        
        required convenience init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
}
