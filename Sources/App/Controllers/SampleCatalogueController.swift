//
//  SampleCatalogueController.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation
import Vapor

extension Dataset: ResponseEncodable {
    func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let encoder = JSONEncoder()
        let body = try encoder.encode(self)
        let response = req.response(body)
        return req.future(response)
    }
}

extension Catalog: ResponseEncodable {
    func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let encoder = JSONEncoder()
        let body = try encoder.encode(self)
        let response = req.response(body)
        return req.future(response)
    }
}

class SampleCatalogueController {
    typealias BiobankDataset = Aggregates<Biobank, Disease>
    typealias BiobankDatasetResponse = AggregateResponse<BiobankDataset>

    private let endPoint = URL(string: "https://samples.rd-connect.eu/api/v2/rd_connect_Sample")!

    enum RequestError: Error {
        case unknown
        case invalidURL(_ string: String)
        case decodeError
        case missingArgument
    }

    private func makeCatalogURL(from req: Request) throws -> URL {
        guard var components = URLComponents(url: endPoint, resolvingAgainstBaseURL: false) else {
            throw RequestError.unknown
        }
        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease"),
        ]
        switch (try? req.query.get(String.self, at: "disease"), try? req.query.get(String.self, at: "biobank")) {
        case (let disease, let biobank) where biobank == nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!)"))
        case (let disease, let biobank) where disease == nil && biobank != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "BiobankID==\(biobank!)"))
        case (let disease, let biobank) where biobank != nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!);BiobankID==\(biobank!)"))
        default:
            break
        }
        guard let url = components.url else {
            throw RequestError.invalidURL(components.description)
        }
        return url
    }

    func catalog(_ req: Request) throws -> Future<Catalog> {
        let url = try makeCatalogURL(from: req)

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Catalog.self) { return try self.makeCatalog($0) }
    }

    private func makeCatalog(_ response: BiobankDatasetResponse) throws -> Catalog {
        var datasets = [URL]()
        for (x, biobank) in response.aggs.xLabels.enumerated() {
            for (y, disease) in response.aggs.yLabels.enumerated() {
                let numberOfPatients = response.aggs.matrix[x][y]

                if numberOfPatients > 0 {
                    if let url = URL(string: "http://localhost:8080/dataset/?disease=\(disease.id)&biobank=\(biobank.id)") {
                        datasets.append(url)
                    }
                }
            }
        }
        let id = URL(string: "https://samples.rd-connect.eu/")!
        let location = Location(city: "Groningen", country: "The Netherlands")
        let publisher = Publisher(name: "University Medical Center Groningen", location: location)
        let catalog = Catalog(id: id, datasets: datasets, publisher: publisher)
        return catalog
    }

    private func makeCollectionURL(from request: Request) throws -> URL {
        let disease = try request.query.get(String.self, at: "disease")
        let biobank = try request.query.get(String.self, at: "biobank")

        guard var components = URLComponents(url: endPoint, resolvingAgainstBaseURL: false) else {
            throw RequestError.unknown
        }
        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease;distinct==ParticipantID"),
            URLQueryItem(name: "q", value: "Disease==\(disease);BiobankID==\(biobank)")
        ]
        guard let url = components.url else {
            throw RequestError.invalidURL(components.description)
        }
        return url
    }

    func dataset(_ req: Request) throws -> Future<Dataset> {
        let url = try makeCollectionURL(from: req)

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Dataset.self) { return try self.makeDataset($0.aggs) }
    }

    private func makeDataset(_ aggregates: BiobankDataset) throws -> Dataset {
        guard let biobank = aggregates.xLabels.first,
            let disease = aggregates.yLabels.first,
            let numberOfPatients = aggregates.matrix.first?.first
            else {
                throw RequestError.decodeError
        }
        var components = URLComponents(string: "http://localhost:8080/")
        components?.queryItems = [
            URLQueryItem(name: "disease", value: disease.url.absoluteString),
            URLQueryItem(name: "biobank", value: biobank.id)
        ]
        guard let url = components?.url else {
            throw RequestError.invalidURL(components?.description ?? "Invalid URL components")
        }

        let theme = Theme(id: disease.url)
        let location = Location(city: biobank.city, country: biobank.country)
        let publisher = Publisher(name: biobank.institute, location: location)

        let dataset = Dataset(id: url, name: biobank.name, theme: [theme], publisher: publisher, numberOfPatients: numberOfPatients)
        return dataset

    }
}
