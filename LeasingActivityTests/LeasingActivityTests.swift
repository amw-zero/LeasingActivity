//
//  LeasingActivityTests.swift
//  LeasingActivityTests
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import XCTest
@testable import LeasingActivity

class LeasingActivityTests: XCTestCase {
    func testCreatingADeal() {
        let shell = DealShell()
        
        shell.createDeal(requirementSize: 1000)
        
        XCTAssertTrue(shell.hasDeal(requirementSize: 1000))
    }
}
