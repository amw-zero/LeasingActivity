import Vapor
import LeasingActivityBehavior

enum DealError: Error {
    case error
}

final class DealController {
    func create(_ req: Request) throws -> Future<Deal> {
        let p = req.eventLoop.newPromise(of: Deal.self)

        if let data = req.http.body.data {
            let s = DealServer()
            s.createDeal(data: data) { result in
                switch result {
                case let .success(deal):
                    let dealRecord = Deal(requirementSize: deal.requirementSize)
                    let saveFuture = dealRecord.save(on: req)
                    saveFuture.whenSuccess { _ in
                        p.succeed(result: dealRecord)
                    }
                    saveFuture.whenFailure { error in
                        p.fail(error: error)
                    }
                case .error:
                    p.fail(error: DealError.error)
                }
                
            }
        } else {
            p.fail(error: DealError.error)
        }
        
        return p.futureResult
    }
}
