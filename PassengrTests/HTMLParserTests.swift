//
//  HTMLParserTests.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/8/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import XCTest

@testable import Passengr

class HTMLParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanParseHTML() {
        let url = Bundle(for: type(of: self)).url(forResource: "test", withExtension: "html")
        let data = try! Data(contentsOf: url!)
        let info = Parser.passInfoFromResponse(response: data)
        
        XCTAssert(info.count == 4, "Info count should be 4")
        XCTAssert(info[PassInfoKeys.Eastbound] == "No restrictions", "eastbound is wrong")
        XCTAssert(info[PassInfoKeys.Westbound] == "No restrictions", "westbound is wrong")
        XCTAssert(info[PassInfoKeys.Conditions] == "The roadway is bare and dry.", "conditions are wrong")
        XCTAssert(info[PassInfoKeys.LastUpdated] == "Saturday November 5, 1955 9:41 AM", "last updated is wrong")
    }
    
}
