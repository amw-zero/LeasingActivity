//
//  LeasingActivityTests.swift
//  LeasingActivityTests
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import XCTest
@testable import LeasingActivity

class ServerRepository {
    var successfulResponse = true
}

class DealShell {
    let repository: ServerRepository
    
    init(repository: ServerRepository) {
        self.repository = repository
    }
    
    func createDeal(requirementSize: Int) {
        
    }
}

extension DealShell {
    func hasDeal(requirementSize: Int) -> Bool {
        return true
    }
}

func makeDealShell(isResponseSuccessful: Bool = true) -> DealShell {
    let repository = ServerRepository()
    repository.successfulResponse = isResponseSuccessful
    
    return DealShell(repository: repository)
}

class LeasingActivityTests: XCTestCase {
    func testCreatingADealSuccessfully() {
        let shell = makeDealShell()
        
        shell.createDeal(requirementSize: 1000)
        
        XCTAssertTrue(shell.hasDeal(requirementSize: 1000))
    }
    
    func testCreatingADealError() {
        let shell = makeDealShell(isResponseSuccessful: false)
        
        shell.createDeal(requirementSize: 1000)
        
        XCTAssertFalse(shell.hasDeal(requirementSize: 1000))
    }
}
