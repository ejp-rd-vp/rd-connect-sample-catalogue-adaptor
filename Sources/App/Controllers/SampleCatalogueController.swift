//
//  SampleCatalogueController.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation
import Vapor

class SampleCatalogueController {

    func catalog(_ req: Request) throws -> Future<Catalog> {
        let url = try makeCatalogURL(from: req)

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Catalog.self) { return try Catalog(from: $0) }
    }

    func dataset(_ req: Request) throws -> Future<Dataset> {
        let url = try makeCollectionURL(from: req)

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Dataset.self) { return try Dataset(from: $0.data) }
    }

    private enum RequestError: Error {
        case unknown
        case invalidURL(_ string: String)
    }

    private let endPoint = URL(string: "https://samples.rd-connect.eu/api/v2/rd_connect_Sample")!

    func makeCatalogURL(from request: Request) throws -> URL {
        var components = URLComponents(url: endPoint, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease"),
        ]
        let disease = try? request.query.get(String.self, at: "disease")
        let biobank = try? request.query.get(String.self, at: "biobank")
        if let biobank = biobank, let disease = disease {
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease);BiobankID==\(biobank)"))
        } else if let disease = disease {
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease)"))
        } else if let biobank = biobank {
            components.queryItems?.append(URLQueryItem(name: "q", value: "BiobankID==\(biobank)"))
        }
        guard let url = components.url else {
            throw RequestError.invalidURL(components.description)
        }
        return url
    }

    func makeCollectionURL(from request: Request) throws -> URL {
        var components = URLComponents(url: endPoint, resolvingAgainstBaseURL: false)!
        let disease = try request.query.get(String.self, at: "disease")
        let biobank = try request.query.get(String.self, at: "biobank")

        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease;distinct==ParticipantID"),
            URLQueryItem(name: "q", value: "Disease==\(disease);BiobankID==\(biobank)")
        ]
        guard let url = components.url else {
            throw RequestError.invalidURL(components.description)
        }
        return url
    }
}
