//
//  LeasingActivityTests.swift
//  LeasingActivityTests
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import XCTest
@testable import LeasingActivity

enum NetworkResult<T> {
    case error
    case success(T)
}

struct Deal {
    let id: Int?
    let requirementSize: Int
}

protocol ServerRepository {
    var successfulResponse: Bool { get set }
    
    func createDeal(requirementSize: Int, onComplete: (NetworkResult<Deal>) -> Void)
}

struct StubServerRepository: ServerRepository {
    var successfulResponse: Bool = true
    
    func createDeal(requirementSize: Int, onComplete: (NetworkResult<Deal>) -> Void) {
        if successfulResponse {
            onComplete(.success(Deal(id: 1, requirementSize: requirementSize)))
        } else {
            onComplete(.error)
        }
    }
}

class DealShell {
    let repository: ServerRepository
    var deals: [Deal] = []
    
    init(repository: ServerRepository) {
        self.repository = repository
    }
    
    func createDeal(requirementSize: Int) {
        repository.createDeal(requirementSize: requirementSize) { result in
            switch result {
            case let .success(deal):
                deals.append(deal)
            default:
                break
            }
        }
    }
}

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
