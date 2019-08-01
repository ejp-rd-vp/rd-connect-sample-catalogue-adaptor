import Routing
import Vapor

public func routes(_ router: Router) throws {
    let catalog = Environment.get("catalogURL") ?? "https://samples.rd-connect.eu/"
    guard let url = URL(string: catalog) else { fatalError("Failed to configure remote endpoint. Set catalogURL.")}
    let local = Environment.get("localURL") ?? "http://localhost:8080/"
    guard let localURL = URL(string: local) else { fatalError("Failed to configure local endpoint. Set localURL.")}
    let controller = SampleCatalogueController(catalog: url, localURL: localURL)
    router.get("/dataset", use: controller.dataset)
    router.get("/catalog", use: controller.catalog)
}
