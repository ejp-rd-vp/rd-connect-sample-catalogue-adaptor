import Foundation
import Vapor
import EJPRDMetadata

extension Catalog: Content {

    init(from response: BiobankDatasetResponse, for url: URL) throws {
        var datasets = [URL]()
        for (x, biobank) in response.data.biobanks.enumerated() {
            for (y, disease) in response.data.diseases.enumerated() {
                let numberOfPatients = response.data.counts[x][y]

                if numberOfPatients > 0 {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    components?.path = "/dataset/"
                    components?.queryItems = [
                        URLQueryItem(name: "disease", value: disease.compactID),
                        URLQueryItem(name: "biobank", value: biobank.id)
                    ]
                    if let url = components?.url {
                        datasets.append(url)
                    }
                }
            }
        }
        let catalog = Environment.get("catalogURL") ?? "https://samples.rd-connect.eu/"
        guard let id = URL(string: catalog) else { fatalError("Failed to configure remote endpoint. Set catalogURL.")}
        let location = Location(city: "Groningen", country: "The Netherlands")
        let publisher = Publisher(name: "University Medical Center Groningen", location: location)
        self.init(id: id, datasets: datasets, publisher: publisher)
    }
}

