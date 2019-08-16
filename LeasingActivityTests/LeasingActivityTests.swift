//
//  LeasingActivityTests.swift
//  LeasingActivityTests
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import XCTest
@testable import LeasingActivity

extension DealShell {
    func hasDeal(id: Int) -> Bool {
        deals.contains { $0.id == id }
    }
}

func makeDealShell(isResponseSuccessful: Bool = true) -> DealShell {
    var repository = StubServerRepository()
    repository.successfulResponse = isResponseSuccessful
    
    return DealShell(repository: repository)
}

class LeasingActivityTests: XCTestCase {
    func testCreatingADealSuccessfully() {
        let shell = makeDealShell()
        
        shell.createDeal(requirementSize: 1000)
        
        XCTAssertTrue(shell.hasDeal(id: 1))
    }
    
    func testCreatingADealError() {
        let shell = makeDealShell(isResponseSuccessful: false)
        
        shell.createDeal(requirementSize: 1000)
        
        XCTAssertFalse(shell.hasDeal(id: 1))
    }
}
