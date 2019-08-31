import Vapor

final class DealController {
    func create(_ req: Request) throws -> Future<Deal> {
        return try req.content.decode(Deal.self).flatMap { deal in
            return deal.save(on: req)
        }
    }
}