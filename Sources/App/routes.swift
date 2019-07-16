import Routing
import Vapor

public func routes(_ router: Router) throws {
    router.get("/dataset", use: SampleCatalogueController().dataset)
    router.get("/catalog", use: SampleCatalogueController().catalog)
}
