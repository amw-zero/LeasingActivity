import Vapor
import LeasingActivityBehavior

enum DealError: Error {
    case error
}

extension Data: ResponseEncodable {
    public func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let jsonDataHeaders: HTTPHeaders = ["content-type": "application/json"]
        let res = Response(http: .init(headers: jsonDataHeaders, body: self), using: req.sharedContainer)
        return req.sharedContainer.eventLoop.newSucceededFuture(result: res)
    }
}

func createDeal(onRequest req: Request) ->
    (LeasingActivityBehavior.Deal, @escaping (LeasingActivityBehavior.Deal) -> Void) -> Void {
    return { deal, onComplete in
        let dealRecord = Deal(requirementSize: deal.requirementSize)
        let saveFuture = dealRecord.save(on: req)
        saveFuture.whenSuccess { d in
            onComplete(LeasingActivityBehavior.Deal(id: d.id, requirementSize: d.requirementSize))
        }
        saveFuture.whenFailure { error in
            
        }
    }
}

func findDeals(onRequest req: Request) -> (@escaping DealServer.DealsFunc) -> Void {
    return { onComplete in
        let dealQuery = Deal.query(on: req).all()
        dealQuery.whenSuccess { deals in
            onComplete(deals.map {
                LeasingActivityBehavior.Deal(id: $0.id, requirementSize: $0.requirementSize)
            })
        }
        dealQuery.whenFailure { _ in }
    }
}

final class DealController {
    func create(_ req: Request) throws -> Future<Data> {
        let p = req.eventLoop.newPromise(of: Data.self)
        if let data = req.http.body.data {
            DealServer(
                createRepository: createDeal(onRequest: req),
                indexRepository: { _ in }
            ).createDeal(data: data) { result in
                switch result {
                case let .success(dealData):
                    p.succeed(result: dealData)
                case .error:
                    p.fail(error: DealError.error)
                }
            }
        } else {
            p.fail(error: DealError.error)
        }
        
        return p.futureResult
    }
    
    func index(_ req: Request) throws -> Future<Data> {
        let p = req.eventLoop.newPromise(of: Data.self)
        DealServer(
            createRepository: { _, _ in },
            indexRepository: findDeals(onRequest: req)
        ).viewDeals { result in
            switch result {
            case let .success(dealData):
                p.succeed(result: dealData)
            case .error:
                p.fail(error: DealError.error)
            }
        }
        
        return p.futureResult
    }
}
