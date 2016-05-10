//
//  SwiftMetalForOSXUITests.swift
//  SwiftMetalForOSXUITests
//
//  Created by Amund Tveit on 10/06/15.
//  Copyright © 2015 Amund Tveit. All rights reserved.
//

import Foundation
import XCTest

class SwiftMetalForOSXUITests: XCTestCase {
    
    var vc: ViewController!
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoublerWithMetal() {
        
        
//        let N = 100
//        let inputVector = vc.createInputVector(N)
//        var outputVector = vc.doublerWithMetal(inputVector)
//        print("test..")
//        print("iv = \(inputVector)")
//        print("ov = \(outputVector)")
        
        assert(true)
    }
    
}
