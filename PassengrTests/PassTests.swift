//
//  PassTests.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/9/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import XCTest

@testable import Passengr

class PassTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCanUpdatePass() {
        let pass = testablePass()
        
        pass.updateUsingPassInfo(info)
        
        XCTAssert(pass.name == "Pass Name", "pass name is wrong")
        XCTAssert(pass.conditions == "Pass Conditions", "pass conditions are wrong")
        XCTAssert(pass.url == "http://someurl.com", "pass url is wrong")
        XCTAssert(pass.westbound == "No Restrictions", "westbound is wrong")
        XCTAssert(pass.eastbound == "Pass Closed", "eastbound is wrong")
    }
    
    func testPassIsClosed() {
        let pass = testablePass()
        
        pass.westbound = "Pass Closed"
        pass.eastbound = "No Restrictions"
        
        XCTAssert(pass.closed, "pass should be closed")
    }
    
    func testPassIsOpen() {
        let pass = testablePass()
        
        pass.westbound = "No Restrictions"
        pass.eastbound = "No Restrictions"
        
        XCTAssert(pass.open, "pass should be open")
    }
    
    func testPassHasRestrictions() {
        let pass = testablePass()
        
        pass.westbound = "Some hazards"
        pass.eastbound = "No Restrictions"
        
        XCTAssert(pass.open == false, "pass should not be open")
        XCTAssert(pass.closed == false, "pass should not be closed")
    }
    
    private func testablePass() -> Passengr.Pass {
        return Passengr.Pass(name: "Pass Name", url: "http://someurl.com", order: 1, enabled: true)
    }
    
    private var info: PassInfo {
        return [
            PassInfoKeys.Title: "Pass Name",
            PassInfoKeys.Conditions: "Pass Conditions",
            PassInfoKeys.ReferenceURL: "http://someurl.com",
            PassInfoKeys.Westbound: "No Restrictions",
            PassInfoKeys.Eastbound: "Pass Closed"
        ]
    }
}
