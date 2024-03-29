import Vapor

public func routes(_ router: Router) throws {
    let dealController = DealController()
    router.post("deals", use: dealController.create)
    router.get("deals", use: dealController.index)
}
