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

func createDeal(onConnectable conn: DatabaseConnectable) ->
    (LeasingActivityBehavior.Deal, @escaping (LeasingActivityBehavior.Deal) -> Void) -> Void {
    return { deal, onComplete in
        let dealRecord = Deal(requirementSize: deal.requirementSize, tenantName: deal.tenantName)
        let saveFuture = dealRecord.save(on: conn)
        saveFuture.whenSuccess { d in
            onComplete(LeasingActivityBehavior.Deal(id: d.id, requirementSize: d.requirementSize, tenantName: d.tenantName))
        }
        saveFuture.whenFailure { error in
            
        }
    }
}

func findDeals(onConnectable conn: DatabaseConnectable) -> (DealFilter, @escaping DealServer.DealsFunc) -> Void {
    return { filter, onComplete in
        let dealQuery: Future<[Deal]>
        switch filter {
        case .all:
            dealQuery = Deal.query(on: conn).all()
        case let .tenantName(tenantName):
            dealQuery = Deal.query(on: conn).filter(\.tenantName, .equal, tenantName).all()
        }
        
        dealQuery.whenSuccess { deals in
            onComplete(deals.map {
                LeasingActivityBehavior.Deal(id: $0.id, requirementSize: $0.requirementSize, tenantName: $0.tenantName)
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
                createRepository: createDeal(onConnectable: req),
                indexRepository: { _, _ in }
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
            indexRepository: findDeals(onConnectable: req)
        ).viewDeals(filter: .all) { result in
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
