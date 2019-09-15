@testable import App
import LeasingActivityBehavior
import Vapor
import XCTest

func makeVaporDealIndexRepository(
    withConnection conn: DatabaseConnectable
) -> ([LeasingActivityBehavior.Deal], DealFilter, @escaping DealServer.DealsFunc) -> Void {
    return { deals, filter, onComplete in
        let group = DispatchGroup()
        for deal in deals {
            group.enter()
            let createRepo = createDeal(onConnectable: conn)
            createRepo(deal) { _ in group.leave() }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let indexRepo = findDeals(onConnectable: conn)
            indexRepo(filter, onComplete)
        }
    }
}

final class AppTests: XCTestCase {
    func testFindDealsRepository() throws {
        let application = try app(.detect())
        try App.boot(application)
        
        let conn = try application.newConnection(to: .sqlite).wait()
        let expectation = self.expectation(description: "sqlite repository")
        
        indexRepositoryContract(makeVaporDealIndexRepository(withConnection: conn)) { success in
            expectation.fulfill()
            XCTAssert(success)
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    static let allTests = [
        ("testNothing", testFindDealsRepository)
    ]
}
